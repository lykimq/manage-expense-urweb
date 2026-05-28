fun loadExpense expenseId =
    expenseOpt <- Expense_db.getById expenseId;
    case expenseOpt of
        None =>
        (Log.warn "expense_service" ("expense not found: id=" ^ show expenseId);
         error <xml><p><b>Expense not found.</b></p></xml>)
      | Some expense => return expense

fun expenseState expense =
    case State.fromString expense.State of
        None =>
        (Log.warn "expense_service"
           ("invalid expense state: " ^ expense.State ^ " id=" ^ show expense.Id);
         error <xml><p><b>Invalid expense state.</b></p></xml>)
      | Some state => return state

fun requireTransition allowed state actionLabel =
    if allowed then
        return ()
    else
        (Log.warn "expense_service"
           ("transition rejected: " ^ actionLabel ^ " from " ^ show state);
         error <xml><p><b>This action is not allowed for the current expense state.</b></p></xml>)

fun applyTransition userId expense expenseId newState comment =
    let val oldState = expense.State in
        stamp <- now;
        Expense_db.updateState expenseId (show newState) stamp;
        _ <- Audit_db.insert {ExpenseId = expenseId,
                              ActorId = userId,
                              OldState = oldState,
                              NewState = show newState,
                              Comment = comment};
        return ()
    end

fun parseAmountValue s =
    read s : option float

fun parseAmount s =
    case parseAmountValue s of
        None => error <xml><p><b>Amount must be a valid number.</b></p></xml>
      | Some amount => return amount

fun create userId fields =
    Policy.requireRole Roles.Employee userId;
    amount <- parseAmount fields.Amount;
    expenseId <- Expense_db.create {Title = fields.Title,
                                    Amount = amount,
                                    Category = fields.Category,
                                    Description = fields.Description,
                                    OwnerId = userId,
                                    State = show State.Submitted};
    _ <- Audit_db.insert {ExpenseId = expenseId,
                          ActorId = userId,
                          OldState = "",
                          NewState = show State.Submitted,
                          Comment = "Submitted for approval"};
    Log.info "expense_service" ("create expense_id=" ^ show expenseId);
    return expenseId

fun approve userId expenseId comment =
    Policy.requireRole Roles.Manager userId;
    expense <- loadExpense expenseId;
    Policy.requireNotOwner userId expense.OwnerId;
    state <- expenseState expense;
    requireTransition (Transition.canApprove state) state "approve";
    applyTransition userId expense expenseId State.Approved comment

fun reject userId expenseId comment =
    Policy.requireRole Roles.Manager userId;
    expense <- loadExpense expenseId;
    Policy.requireNotOwner userId expense.OwnerId;
    state <- expenseState expense;
    requireTransition (Transition.canReject state) state "reject";
    applyTransition userId expense expenseId State.Rejected comment

fun pay userId expenseId =
    Policy.requireRole Roles.Finance userId;
    expense <- loadExpense expenseId;
    state <- expenseState expense;
    requireTransition (Transition.canPay state) state "pay";
    applyTransition userId expense expenseId State.Paid "Marked paid"

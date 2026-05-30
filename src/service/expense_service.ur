(* Business rules for submitting, approving, rejecting, and paying expenses. *)

(* Load an expense by id; stop with an error if it does not exist. *)
fun loadExpense expenseId =
    expenseOpt <- Expense_db.getById expenseId;
    case expenseOpt of
        None =>
        (Log.warn "expense_service" ("expense not found: id=" ^ show expenseId);
         error <xml><p><b>Expense not found.</b></p></xml>)
      | Some expense => return expense

(* Read the expense state from the database string; stop if it is not a known value. *)
fun expenseState expense =
    case State.fromString expense.State of
        None =>
        (Log.warn "expense_service"
           ("invalid expense state: " ^ expense.State ^ " id=" ^ show expense.Id);
         error <xml><p><b>Invalid expense state.</b></p></xml>)
      | Some state => return state

(* Stop with an error when the requested action is not allowed in the current state. *)
fun requireTransition allowed state actionLabel =
    if allowed then
        return ()
    else
        (Log.warn "expense_service"
           ("transition rejected: " ^ actionLabel ^ " from " ^ show state);
         error <xml><p><b>This action is not allowed for the current expense state.</b></p></xml>)

(* Change the expense state, update the database, and write one audit log entry. *)
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

fun validateAmount amount =
    amount > 0.0

(* Check an amount string and return (ok, message) without stopping the page. Used by RPC and the form. *)
fun amountCheckResult amount =
    case parseAmountValue amount of
        None =>
        (False, "Amount must be a valid number (same rule as on submit).")
      | Some parsed =>
        if validateAmount parsed then
            (True, "Valid amount: " ^ show parsed)
        else
            (False, "Amount must be greater than zero (same rule as on submit).")

(* Parse and validate an amount string; stop with an error if it is missing or not positive. *)
fun parseAmount s =
    case parseAmountValue s of
        None => error <xml><p><b>Amount must be a valid number.</b></p></xml>
      | Some amount =>
        if validateAmount amount then
            return amount
        else
            error <xml><p><b>Amount must be greater than zero.</b></p></xml>

(* RPC entry point: employee only, returns the same (ok, message) pair as amountCheckResult. *)
fun checkAmount userId amount =
    Policy.requireRole Roles.Employee userId;
    return (amountCheckResult amount)

(* Employee submits a new expense in Submitted state and records the first audit entry. *)
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

(* Manager approves a Submitted expense; cannot approve their own expense. *)
fun approve userId expenseId comment =
    Policy.requireRole Roles.Manager userId;
    expense <- loadExpense expenseId;
    Policy.requireNotOwner userId expense.OwnerId;
    state <- expenseState expense;
    requireTransition (Transition.canApprove state) state "approve";
    applyTransition userId expense expenseId State.Approved comment

(* Manager rejects a Submitted expense; cannot reject their own expense. *)
fun reject userId expenseId comment =
    Policy.requireRole Roles.Manager userId;
    expense <- loadExpense expenseId;
    Policy.requireNotOwner userId expense.OwnerId;
    state <- expenseState expense;
    requireTransition (Transition.canReject state) state "reject";
    applyTransition userId expense expenseId State.Rejected comment

(* Finance marks an Approved expense as Paid. *)
fun pay userId expenseId =
    Policy.requireRole Roles.Finance userId;
    expense <- loadExpense expenseId;
    state <- expenseState expense;
    requireTransition (Transition.canPay state) state "pay";
    applyTransition userId expense expenseId State.Paid "Marked paid"

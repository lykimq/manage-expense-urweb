(* Pick which expenses to show on the home page and approval queue, based on role. *)

fun panelTitle role =
    case role of
        Roles.Employee => "My Expenses"
      | Roles.Manager => "Awaiting approval"
      | Roles.Finance => "Awaiting payment"

fun loadExpenses role userId =
    case role of
        Roles.Employee => Expense_db.getByOwner userId
      | Roles.Manager => Expense_db.getByState (show State.Submitted)
      | Roles.Finance => Expense_db.getByState (show State.Approved)

fun loadWorkspace role userId =
    expenses <- loadExpenses role userId;
    return {PanelTitle = panelTitle role, Expenses = expenses}

fun queuePanelTitle role =
    case role of
        Roles.Manager => "Submitted Expenses"
      | Roles.Finance => "Approved Expenses"
      | _ => "Approval Queue"

fun loadQueueWorkspace role userId =
    case role of
        Roles.Manager =>
        exps <- Expense_db.getByState (show State.Submitted);
        return {PanelTitle = queuePanelTitle role, Expenses = exps}
      | Roles.Finance =>
        exps <- Expense_db.getByState (show State.Approved);
        return {PanelTitle = queuePanelTitle role, Expenses = exps}
      | _ =>
        error <xml><p><b>You are not allowed to view the approval queue.</b></p></xml>

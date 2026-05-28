fun panelTitle role =
    case role of
        "Employee" => "My Expenses"
      | "Manager" => "Awaiting approval"
      | "Finance" => "Awaiting payment"
      | _ => "Expenses"

fun loadExpenses role userId =
    case role of
        "Employee" => Expense_db.getByOwner userId
      | "Manager" => Expense_db.getByState (show State.Submitted)
      | "Finance" => Expense_db.getByState (show State.Approved)
      | _ => return []

fun loadWorkspace role userId =
    expenses <- loadExpenses role userId;
    return {PanelTitle = panelTitle role, Expenses = expenses}

fun queuePanelTitle role =
    case role of
        "Manager" => "Submitted Expenses"
      | "Finance" => "Approved Expenses"
      | _ => "Approval Queue"

fun loadQueueWorkspace role userId =
    case role of
        "Manager" =>
        exps <- Expense_db.getByState (show State.Submitted);
        return {PanelTitle = queuePanelTitle role, Expenses = exps}
      | "Finance" =>
        exps <- Expense_db.getByState (show State.Approved);
        return {PanelTitle = queuePanelTitle role, Expenses = exps}
      | _ =>
        error <xml><p><b>You are not allowed to view the approval queue.</b></p></xml>

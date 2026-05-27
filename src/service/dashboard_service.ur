fun panelTitle role =
    case role of
        "Employee" => "My Expenses"
      | "Manager" => "Awaiting approval"
      | "Finance" => "Awaiting payment"
      | _ => "Expenses"

fun loadExpenses role userId =
    case role of
        "Employee" => Expense_db.getByOwner userId
      | "Manager" => Expense_db.getByState (State.toString State.Submitted)
      | "Finance" => Expense_db.getByState (State.toString State.Approved)
      | _ => return []

fun loadWorkspace role userId =
    expenses <- loadExpenses role userId;
    return {PanelTitle = panelTitle role, Expenses = expenses}

val groupName = "dashboard_service"

type dashboard_request = {Role : string, UserId : int}

fun loadWorkspace req =
    Dashboard_service.loadWorkspace req.Role req.UserId

fun loadQueueWorkspace req =
    Dashboard_service.loadQueueWorkspace req.Role req.UserId

fun hasExpenseId expenseId expenses =
    case expenses of
        [] => False
      | e :: rest =>
        if e.Id = expenseId then True else hasExpenseId expenseId rest

fun allInState expectedState expenses =
    case expenses of
        [] => True
      | e :: rest =>
        e.State = expectedState && allInState expectedState rest

fun runAll () : transaction (list Test_harness.test_result) =
    submittedId <- Expense_service.create 1
                   {Title = "Dashboard submitted expense",
                    Amount = "19.99",
                    Category = "Travel",
                    Description = "Dashboard test submitted"};
    approvedId <- Expense_service.create 1
                  {Title = "Dashboard approved expense",
                   Amount = "29.99",
                   Category = "Office",
                   Description = "Dashboard test approved"};
    Expense_service.approve 2 approvedId "Approve dashboard test expense";

    employeeWorkspace <- loadWorkspace {Role = "Employee", UserId = 1};
    managerWorkspace <- loadWorkspace {Role = "Manager", UserId = 2};
    financeWorkspace <- loadWorkspace {Role = "Finance", UserId = 3};
    managerQueue <- loadQueueWorkspace {Role = "Manager", UserId = 2};
    financeQueue <- loadQueueWorkspace {Role = "Finance", UserId = 3};

    let
        val employeeOwnExpensesVisible =
            hasExpenseId submittedId employeeWorkspace.Expenses
            && hasExpenseId approvedId employeeWorkspace.Expenses
        val managerSeesSubmittedOnly =
            hasExpenseId submittedId managerWorkspace.Expenses
            && allInState (show State.Submitted) managerWorkspace.Expenses
        val financeSeesApprovedOnly =
            hasExpenseId approvedId financeWorkspace.Expenses
            && allInState (show State.Approved) financeWorkspace.Expenses
        val managerQueueMatchesRole =
            managerQueue.PanelTitle = "Submitted Expenses"
            && hasExpenseId submittedId managerQueue.Expenses
        val financeQueueMatchesRole =
            financeQueue.PanelTitle = "Approved Expenses"
            && hasExpenseId approvedId financeQueue.Expenses
    in
        return (Test_harness.mkResult "employee workspace returns owner expenses" employeeOwnExpensesVisible ::
                Test_harness.mkResult "manager workspace returns submitted queue" managerSeesSubmittedOnly ::
                Test_harness.mkResult "finance workspace returns approved queue" financeSeesApprovedOnly ::
                Test_harness.mkResult "manager queue workspace has title and submitted data" managerQueueMatchesRole ::
                Test_harness.mkResult "finance queue workspace has title and approved data" financeQueueMatchesRole ::
                [])
    end

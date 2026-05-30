(* Integration tests for role-specific dashboard and approval queue lists. *)

open Tables

val groupName = "dashboard_service"

type dashboard_request = {Role : Roles.role, UserId : int}

fun loadWorkspace req =
    Dashboard_service.loadWorkspace req.Role req.UserId

fun loadQueueWorkspace req =
    Dashboard_service.loadQueueWorkspace req.Role req.UserId

(* Seed expenses, load each role view, then check titles and filtered rows. *)
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

    employeeWorkspace <- loadWorkspace {Role = Roles.Employee, UserId = 1};
    managerWorkspace <- loadWorkspace {Role = Roles.Manager, UserId = 2};
    financeWorkspace <- loadWorkspace {Role = Roles.Finance, UserId = 3};
    managerQueue <- loadQueueWorkspace {Role = Roles.Manager, UserId = 2};
    financeQueue <- loadQueueWorkspace {Role = Roles.Finance, UserId = 3};

    let
        val employeeOwnExpensesVisible =
            Test_data_utils.hasExpenseId submittedId employeeWorkspace.Expenses
            && Test_data_utils.hasExpenseId approvedId employeeWorkspace.Expenses
        val managerSeesSubmittedOnly =
            Test_data_utils.hasExpenseId submittedId managerWorkspace.Expenses
            && Test_data_utils.allInState (show State.Submitted) managerWorkspace.Expenses
        val financeSeesApprovedOnly =
            Test_data_utils.hasExpenseId approvedId financeWorkspace.Expenses
            && Test_data_utils.allInState (show State.Approved) financeWorkspace.Expenses
        val managerQueueMatchesRole =
            managerQueue.PanelTitle = "Submitted Expenses"
            && Test_data_utils.hasExpenseId submittedId managerQueue.Expenses
        val financeQueueMatchesRole =
            financeQueue.PanelTitle = "Approved Expenses"
            && Test_data_utils.hasExpenseId approvedId financeQueue.Expenses
    in
        Test_data_utils.cleanupExpense submittedId;
        Test_data_utils.cleanupExpense approvedId;
        return (Test_harness.mkResult "employee workspace returns owner expenses" employeeOwnExpensesVisible ::
                Test_harness.mkResult "manager workspace returns submitted queue" managerSeesSubmittedOnly ::
                Test_harness.mkResult "finance workspace returns approved queue" financeSeesApprovedOnly ::
                Test_harness.mkResult "manager queue workspace has title and submitted data" managerQueueMatchesRole ::
                Test_harness.mkResult "finance queue workspace has title and approved data" financeQueueMatchesRole ::
                [])
    end

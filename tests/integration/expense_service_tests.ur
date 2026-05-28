open Tables

type create_case_out =
    {ExpenseId : int,
     Results : list Test_harness.test_result}

val groupName = "expense_service"

fun cleanupExpense expenseId =
    dml (DELETE FROM audit_log WHERE ExpenseId = {[expenseId]});
    dml (DELETE FROM expenses WHERE Id = {[expenseId]})

fun testCreateCase () : transaction create_case_out =
    expenseId <- Expense_service.create 1
                {Title = "Integration expense",
                 Amount = "12.50",
                 Category = "Travel",
                 Description = "Integration test flow"};
    createdExpenseOpt <- Expense_db.getById expenseId;
    createdAudit <- Audit_db.getByExpense expenseId;
    let
        val createStateOk =
            case createdExpenseOpt of
                Some e => e.State = show State.Submitted
              | None => False
        val createAuditOk = List.length createdAudit = 1
    in
        return {ExpenseId = expenseId,
                Results =
                    Test_harness.mkResult "create sets state to Submitted" createStateOk ::
                    Test_harness.mkResult "create writes exactly one audit row" createAuditOk ::
                    []}
    end

fun testApproveCase expenseId : transaction (list Test_harness.test_result) =
    Expense_service.approve 2 expenseId "Approved by integration test";
    approvedExpenseOpt <- Expense_db.getById expenseId;
    approvedAudit <- Audit_db.getByExpense expenseId;
    let
        val approveStateOk =
            case approvedExpenseOpt of
                Some e => e.State = show State.Approved
              | None => False
        val approveAuditOk = List.length approvedAudit = 2
    in
        return (Test_harness.mkResult "approve sets state to Approved" approveStateOk ::
                Test_harness.mkResult "approve appends one audit row" approveAuditOk ::
                [])
    end

fun testPayCase expenseId : transaction (list Test_harness.test_result) =
    Expense_service.pay 3 expenseId;
    paidExpenseOpt <- Expense_db.getById expenseId;
    paidAudit <- Audit_db.getByExpense expenseId;
    let
        val payStateOk =
            case paidExpenseOpt of
                Some e => e.State = show State.Paid
              | None => False
        val payAuditOk = List.length paidAudit = 3
    in
        return (Test_harness.mkResult "pay sets state to Paid" payStateOk ::
                Test_harness.mkResult "pay appends one audit row" payAuditOk ::
                [])
    end

fun runAll () : transaction (list Test_harness.test_result) =
    createOut <- testCreateCase ();
    approveResults <- testApproveCase createOut.ExpenseId;
    payResults <- testPayCase createOut.ExpenseId;
    cleanupExpense createOut.ExpenseId;
    return (List.append createOut.Results (List.append approveResults payResults))

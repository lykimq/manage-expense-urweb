(* Integration tests for create, approve, reject, and pay against the database. *)

open Tables

type create_case_out =
    {ExpenseId : int,
     Results : list Test_harness.test_result}

val groupName = "expense_service"

(* Create an expense and check Submitted state plus the first audit row. *)
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

(* Approve the expense and check Approved state plus a second audit row. *)
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

(* Mark the expense paid and check Paid state plus a third audit row. *)
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

(* Create a separate expense, reject it, then clean up test data. *)
fun testRejectCase () : transaction (list Test_harness.test_result) =
    rejectedId <- Expense_service.create 1
                 {Title = "Integration reject expense",
                  Amount = "8.25",
                  Category = "Meals",
                  Description = "Reject integration test flow"};
    Expense_service.reject 2 rejectedId "Rejected by integration test";
    rejectedExpenseOpt <- Expense_db.getById rejectedId;
    rejectedAudit <- Audit_db.getByExpense rejectedId;
    let
        val rejectStateOk =
            case rejectedExpenseOpt of
                Some e => e.State = show State.Rejected
              | None => False
        val rejectAuditOk = List.length rejectedAudit = 2
    in
        Test_data_utils.cleanupExpense rejectedId;
        return (Test_harness.mkResult "reject sets state to Rejected" rejectStateOk ::
                Test_harness.mkResult "reject appends one audit row" rejectAuditOk ::
                [])
    end

(* Run the full submit-approve-pay path, then a separate reject case. *)
fun runAll () : transaction (list Test_harness.test_result) =
    createOut <- testCreateCase ();
    approveResults <- testApproveCase createOut.ExpenseId;
    payResults <- testPayCase createOut.ExpenseId;
    rejectResults <- testRejectCase ();
    Test_data_utils.cleanupExpense createOut.ExpenseId;
    return (List.append createOut.Results
            (List.append approveResults
             (List.append payResults rejectResults)))

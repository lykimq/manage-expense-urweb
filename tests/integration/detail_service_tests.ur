(* Integration tests for expense detail load, owner name, and audit history. *)

open Tables

(* True when the audit list includes a move from oldState to newState. *)
fun hasTransition oldState newState entries =
    case entries of
        [] => False
      | entry :: rest =>
        if entry.OldState = oldState && entry.NewState = newState then
            True
        else
            hasTransition oldState newState rest

val groupName = "detail_service"

fun allActorNamesPresent entries =
    case entries of
        [] => True
      | entry :: rest =>
        entry.ActorName <> "" && allActorNamesPresent rest

(* Create and approve an expense, then check detail payload and audit rows. *)
fun runAll () : transaction (list Test_harness.test_result) =
    expenseId <- Expense_service.create 1
                 {Title = "Detail service expense",
                  Amount = "45.00",
                  Category = "Meals",
                  Description = "Detail service integration test"};
    Expense_service.approve 2 expenseId "Approved for detail view";
    payload <- Detail_service.load expenseId;
    ownerOpt <- User_db.getById payload.Expense.OwnerId;
    let
        val expenseMatchesRequestedId = payload.Expense.Id = expenseId
        val ownerNameResolved =
            case ownerOpt of
                None => payload.OwnerName = "Unknown"
              | Some owner => payload.OwnerName = owner.FullName
        val auditIncludesSubmission =
            hasTransition "" (show State.Submitted) payload.Audit
        val auditIncludesApproval =
            hasTransition (show State.Submitted) (show State.Approved) payload.Audit
        val auditActorNamesPresent =
            List.length payload.Audit >= 2
            && allActorNamesPresent payload.Audit
    in
        Test_data_utils.cleanupExpense expenseId;
        return (Test_harness.mkResult "detail load returns requested expense" expenseMatchesRequestedId ::
                Test_harness.mkResult "detail load resolves owner display name" ownerNameResolved ::
                Test_harness.mkResult "detail audit includes submission transition" auditIncludesSubmission ::
                Test_harness.mkResult "detail audit includes approval transition" auditIncludesApproval ::
                Test_harness.mkResult "detail audit rows contain actor names" auditActorNamesPresent ::
                [])
    end

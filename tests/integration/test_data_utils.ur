(* Helpers to set up and clean up test data in the database. *)

open Tables

(* Delete audit rows and the expense row after an integration test. *)
fun cleanupExpense expenseId =
    dml (DELETE FROM audit_log WHERE ExpenseId = {[expenseId]});
    dml (DELETE FROM expenses WHERE Id = {[expenseId]})

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

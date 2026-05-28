(** Shared helper functions for integration tests. *)

val cleanupExpense : int -> transaction unit

val hasExpenseId : int -> list Expense_db.expense -> bool

val allInState : string -> list Expense_db.expense -> bool

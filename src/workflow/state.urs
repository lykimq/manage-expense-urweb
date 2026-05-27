(** Expense workflow states (ADT; stored as strings in SQL). *)

datatype expense_state = Submitted | Approved | Rejected | Paid

val show_expense_state : show expense_state
val toString : expense_state -> string
val fromString : string -> option expense_state

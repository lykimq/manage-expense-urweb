datatype expense_state = Draft | Submitted | Approved | Rejected | Paid

val show_expense_state : show expense_state
val fromString : string -> option expense_state
val toString : expense_state -> string

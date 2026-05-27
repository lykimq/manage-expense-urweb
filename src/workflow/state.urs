(** Expense workflow states and string conversion. *)

datatype expense_state = Draft | Submitted | Approved | Rejected | Paid

val show_expense_state : show expense_state

(* Parse DB/UI state string; None if unknown. *)
val fromString : string -> option expense_state

(* Serialize state for DB/UI. *)
val toString : expense_state -> string

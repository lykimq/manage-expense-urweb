(** Expense workflow: load, create, and state transitions with audit. *)

type expense_fields =
    {Title : string, Amount : string, Category : string, Description : string}

(* Load one expense or error if missing (shared with detail_service). *)
val loadExpense : int -> transaction Expense_db.expense

(* Employee: new expense in Submitted; returns expense Id. *)
val create : int -> expense_fields -> transaction int

(* Manager: Submitted -> Approved. *)
val approve : int -> int -> string -> transaction unit

(* Manager: Submitted -> Rejected. *)
val reject : int -> int -> string -> transaction unit

(* Finance: Approved -> Paid. *)
val pay : int -> int -> transaction unit

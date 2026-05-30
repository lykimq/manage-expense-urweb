(** Expense workflow: load, create, and state transitions with audit. *)

type expense_fields =
    {Title : string, Amount : string, Category : string, Description : string}

(* Load one expense or error if missing (shared with detail_service). *)
val loadExpense : int -> transaction Expense_db.expense

(* Employee: new expense in Submitted; returns expense Id. *)
val create : int -> expense_fields -> transaction int

(* Shared amount parser used by create; None means invalid number input. *)
val parseAmountValue : string -> option float

(* Expense amounts must be strictly positive. *)
val validateAmount : float -> bool

(* RPC/create-expense: (ok, message) without persisting; uses parseAmountValue. *)
val amountCheckResult : string -> bool * string

(* Employee-only; same rule as amountCheckResult after role gate. *)
val checkAmount : int -> string -> transaction (bool * string)

(* Manager: Submitted -> Approved. *)
val approve : int -> int -> string -> transaction unit

(* Manager: Submitted -> Rejected. *)
val reject : int -> int -> string -> transaction unit

(* Finance: Approved -> Paid. *)
val pay : int -> int -> transaction unit

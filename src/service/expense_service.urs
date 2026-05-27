(** Expense workflow actions (auth, transitions, DB, audit in one transaction). *)

type expense_fields =
    {Title : string, Amount : string, Category : string, Description : string}

(* Employee: new expense in Submitted; returns expense Id. *)
val create : int -> expense_fields -> transaction int

(* Manager: Submitted -> Approved. *)
val approve : int -> int -> string -> transaction unit

(* Manager: Submitted -> Rejected. *)
val reject : int -> int -> string -> transaction unit

(* Finance: Approved -> Paid. *)
val pay : int -> int -> transaction unit

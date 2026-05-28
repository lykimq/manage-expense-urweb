(** Expense detail forms: approve, reject, pay. *)

val actionsSection :
    int -> string -> Expense_db.expense -> transaction xbody

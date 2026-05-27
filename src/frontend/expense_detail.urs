(** Expense detail placeholder (metadata, audit, actions). *)

(* Body fragment; expenseId selects the row (placeholder). *)
val content : int -> xbody

(* Full page via Layout.wrap. *)
val page : int -> transaction page

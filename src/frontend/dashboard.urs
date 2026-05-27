(** Dashboard placeholder (my expenses, approvals, payments). *)

(* Body fragment without page wrapper. *)
val content : unit -> xbody

(* Full page via Layout.wrap. *)
val page : unit -> transaction page

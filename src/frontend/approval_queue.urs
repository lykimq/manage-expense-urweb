(** Approval queue page backed by role-based DB queries. *)

(* Body fragment for current signed-in user. *)
val content : unit -> transaction xbody

(* Full page via Layout.wrap. *)
val page : unit -> transaction page

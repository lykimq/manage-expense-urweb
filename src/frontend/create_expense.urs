(** Create expense form (placeholder submit handlers). *)

(* Body fragment without page wrapper. *)
val content : unit -> xbody

(* Full page via Layout.wrap. *)
val page : unit -> transaction page

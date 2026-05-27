(** Create expense form (placeholder; no DB writes yet). *)

(* Form markup only. Role gate on GET is in main.ur (Employee). *)
val content : unit -> xbody

(* Full page via Layout.wrap. POST handler formAction rechecks session and role. *)
val page : unit -> transaction page

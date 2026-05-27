(** Create expense form; POST calls Expense_service.create. *)

(* Form markup only. Role gate on GET is in main.ur (Employee). *)
val content : unit -> xbody

(* Full page via Layout.wrap. POST handler formAction rechecks session and role. *)
val page : unit -> transaction page

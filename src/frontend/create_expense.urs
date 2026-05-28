(** Create expense form; POST calls Expense_service.create. *)

type expense_form = {Title : string, Amount : string, Category : string, Description : string}

(* Required fields check used before service call. *)
val hasRequiredFields : expense_form -> bool

(* Form markup only. Role gate on GET is in main.ur (Employee). *)
val content : unit -> xbody

(* Full page via Layout.wrap. POST handler formAction rechecks session and role. *)
val page : unit -> transaction page

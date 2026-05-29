(** Create expense form; POST calls Expense_service.create. *)

type expense_form = {Title : string, Amount : string, Category : string, Description : string}

(* Required fields check used before service call. *)
val hasRequiredFields : expense_form -> bool

(* RPC demo: parse amount on server without create (same rule as submit). *)
val checkAmountRpc : string -> transaction (bool * string)

(* Form markup; role gate on GET is in main.ur (Employee). *)
val content : source string -> source bool -> source string -> xbody

(* Full page via Layout.wrap. POST handler formAction rechecks session and role. *)
val page : unit -> transaction page

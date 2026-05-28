(** Expense detail page markup (no forms or DB). *)

val pageHeader : unit -> xbody

val metadataSection : Detail_service.expense_detail -> int -> xbody

val auditSection : Detail_service.expense_detail -> xbody

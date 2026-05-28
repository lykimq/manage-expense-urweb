(** Shared role type and conversions across app layers. *)

datatype role = Employee | Manager | Finance

val toString : role -> string
val fromString : string -> option role
val show_role : show role

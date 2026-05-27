(** Decimal amount strings for forms (uses Basis read_float / show_float). *)

(* Form text; None if empty or not parseable as float. *)
val parseFloat : string -> option float

(* Display a stored amount. *)
val amountToString : float -> string

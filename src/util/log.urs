(** Server console logging with LEVEL [component] message lines. *)

(* Verbose trace (guards, redirects). *)
val debug : string -> string -> transaction unit

(* Normal operation (routes, login, logout). *)
val info : string -> string -> transaction unit

(* Recoverable problem (e.g. bad login email). *)
val warn : string -> string -> transaction unit

(* Failure path (reserved for service errors). *)
val error : string -> string -> transaction unit

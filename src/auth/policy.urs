(** Role and ownership checks for workflow actions. *)

(* Abort unless the user exists and users.Role equals expectedRole. *)
val requireRole : string -> int -> transaction unit

(* Abort when actorId is the expense owner (no self-approval). *)
val requireNotOwner : int -> int -> transaction unit

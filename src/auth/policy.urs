(** Role and ownership checks for workflow actions. *)

(* Abort unless the user exists and users.Role equals expectedRole. *)
val requireRole : Roles.role -> int -> transaction unit

(* True when the persisted role string maps to expectedRole. *)
val roleMatches : Roles.role -> string -> bool

(* True when actor can act on owner expense (different user ids). *)
val canActOnExpense : int -> int -> bool

(* Abort when actorId is the expense owner (no self-approval). *)
val requireNotOwner : int -> int -> transaction unit

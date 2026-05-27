(** Read-only access to the users table. *)

type user = {Id : int, FullName : string, Role : string, Email : string}

(* One user by primary key; None if missing. *)
val getById : int -> transaction (option user)

(* Every user row (typical use: admin or tests). *)
val getAll : unit -> transaction (list user)

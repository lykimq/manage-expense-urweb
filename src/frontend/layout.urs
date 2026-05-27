(** Shared HTML page shell (head, CSS, main, optional nav). *)

(* Authenticated layout with Logout; session guard is in main.ur. *)
val wrap : string -> xbody -> transaction page

(* Guest layout (login); no navigation bar. *)
val wrapNoNav : string -> xbody -> transaction page

(** Dashboard markup; loads data via Dashboard_service. *)

type user_info = {FullName : string, Role : string, Email : string}

(* Workspace section for home; caller supplies session user id. *)
val contentForRole :
    user_info -> int -> transaction xbody

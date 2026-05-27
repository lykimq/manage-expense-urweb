(** Post-login home (welcome card and embedded sections). *)

val page :
    {FullName : string, Role : string, Email : string}
    -> transaction page

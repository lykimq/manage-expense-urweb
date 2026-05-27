(** Post-login home: profile card and role-specific workspace. *)

val page :
    {FullName : string, Role : string, Email : string}
    -> transaction page

(** Cookie session, login/logout, and page access guards. *)

(* Set user_session cookie after a successful sign-in. *)
val login : int -> transaction unit

(* Clear session and login_error cookies. *)
val logout : unit -> transaction unit

(* Current user id from cookie, if any. *)
val currentUser : unit -> transaction (option int)

(* Profile fields for the current user, if logged in. *)
val currentUserInfo :
    unit
    -> transaction (option {FullName : string, Role : string, Email : string})

(* Require login; redirect to /Main/login when absent. Returns user id. *)
val requireUser : unit -> transaction int

(* Like requireUser; returns FullName, Role, Email from the database. *)
val requireUserInfo :
    unit
    -> transaction {FullName : string, Role : string, Email : string}

(* Login page only; redirect to /Main/home when already logged in. *)
val requireGuest : unit -> transaction unit

(* Look up email in users; set session on success. *)
val loginByEmail : string -> transaction bool

(* Read and clear the one-shot login_error flash cookie. *)
val consumeLoginError : unit -> transaction (option string)

(* Response headers that discourage browser caching. *)
val setNoCacheHeaders : unit -> transaction unit

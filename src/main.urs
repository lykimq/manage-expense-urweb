(** HTTP routes (see allow url in app.urp). Session and Policy guards run here. *)

(* Guest login page. *)
val login : unit -> transaction page

(* Clear session and return to login. *)
val logout : unit -> transaction page

(* Authenticated home; any role. *)
val home : unit -> transaction page

(* Create expense form; Employee only. *)
val create : unit -> transaction page

(* Dashboard; any logged-in role. *)
val dashboard : unit -> transaction page

(* Expense detail; any logged-in role. *)
val detail : int -> transaction page

(* Approval queue; Manager and Finance only (enforced in service). *)
val queue : unit -> transaction page

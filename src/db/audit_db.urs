(** Append-only access to the audit_log table. *)

(* One row from audit_log (includes Id and Stamp from the database). *)
type audit_entry =
    {Id : int,
     ExpenseId : int,
     ActorId : int,
     OldState : string,
     NewState : string,
     Comment : string,
     Stamp : time}

(* Fields for a new audit row; Id and Stamp are assigned in insert. *)
type audit_new =
    {ExpenseId : int,
     ActorId : int,
     OldState : string,
     NewState : string,
     Comment : string}

(* Insert one row; returns the new audit_log Id. *)
val insert : audit_new -> transaction int

(* All audit rows for an expense (order not guaranteed until ORDER BY is added). *)
val getByExpense : int -> transaction (list audit_entry)

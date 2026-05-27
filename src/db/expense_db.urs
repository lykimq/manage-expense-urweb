(** Read and write access to the expenses table. *)

(* Full expense row from the database. *)
type expense =
    {Id : int,
     Title : string,
     Amount : float,
     Category : string,
     Description : string,
     OwnerId : int,
     State : string,
     CreatedAt : time,
     UpdatedAt : time}

(* Fields for insert; Id and timestamps are assigned in create. *)
type expense_new =
    {Title : string,
     Amount : float,
     Category : string,
     Description : string,
     OwnerId : int,
     State : string}

(* One expense by primary key; None if missing. *)
val getById : int -> transaction (option expense)

(* All expenses owned by a user (employee dashboard). *)
val getByOwner : int -> transaction (list expense)

(* All expenses in a workflow state string (queues, e.g. "Submitted"). *)
val getByState : string -> transaction (list expense)

(* Insert a new expense; returns the new Id. *)
val create : expense_new -> transaction int

(* Update State and UpdatedAt for one expense. *)
val updateState : int -> string -> time -> transaction unit

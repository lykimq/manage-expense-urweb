(** Role-based workspace data for home / dashboard *)

type workspace =
    {PanelTitle : string, Expenses : list Expense_db.expense}

(* Load panel title and expenses for the given role and user id. *)
val loadWorkspace : string -> int -> transaction workspace

(* Queue data for Manager/Finance only; errors for other roles. *)
val loadQueueWorkspace : string -> int -> transaction workspace

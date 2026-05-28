(** Read model for the expense detail page (no workflow mutations). *)

type audit_item =
    {Stamp : time,
     OldState : string,
     NewState : string,
     Comment : string,
     ActorName : string}

type expense_detail =
    {Expense : Expense_db.expense, OwnerName : string, Audit : list audit_item}

val load : int -> transaction expense_detail

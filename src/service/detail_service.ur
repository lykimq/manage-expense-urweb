(* Load one expense with the owner name and full change history for the detail page. *)

fun actorName actorId =
    userOpt <- User_db.getById actorId;
    return (case userOpt of
              None => "User #" ^ show actorId
            | Some user => user.FullName)

fun enrichAuditEntry entry =
    name <- actorName entry.ActorId;
    return {Stamp = entry.Stamp,
            OldState = entry.OldState,
            NewState = entry.NewState,
            Comment = entry.Comment,
            ActorName = name}

fun load expenseId =
    expense <- Expense_service.loadExpense expenseId;
    ownerOpt <- User_db.getById expense.OwnerId;
    ownerName <-
        return (case ownerOpt of
                    None => "Unknown"
                  | Some user => user.FullName);
    rawAudit <- Audit_db.getByExpense expenseId;
    audit <- List.mapM enrichAuditEntry rawAudit;
    return {Expense = expense, OwnerName = ownerName, Audit = audit}

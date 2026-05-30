(* Save and look up the history of changes to each expense. *)

open Tables

type audit_entry =
    {Id : int,
     ExpenseId : int,
     ActorId : int,
     OldState : string,
     NewState : string,
     Comment : string,
     Stamp : time}

type audit_new =
    {ExpenseId : int,
     ActorId : int,
     OldState : string,
     NewState : string,
     Comment : string}

fun rowFromAuditLog r =
    {Id = r.Audit_log.Id,
     ExpenseId = r.Audit_log.ExpenseId,
     ActorId = r.Audit_log.ActorId,
     OldState = r.Audit_log.OldState,
     NewState = r.Audit_log.NewState,
     Comment = r.Audit_log.Comment,
     Stamp = r.Audit_log.Stamp}

fun insert data =
    id <- nextval audit_id_seq;
    stamp <- now;
    dml (INSERT INTO audit_log (Id, ExpenseId, ActorId, OldState, NewState,
                                Comment, Stamp)
         VALUES ({[id]}, {[data.ExpenseId]}, {[data.ActorId]}, {[data.OldState]},
                 {[data.NewState]}, {[data.Comment]}, {[stamp]}));
    return id

fun getByExpense expenseId =
    rows <- query (SELECT audit_log.Id, audit_log.ExpenseId, audit_log.ActorId,
                          audit_log.OldState, audit_log.NewState, audit_log.Comment,
                          audit_log.Stamp
                   FROM audit_log
                   WHERE audit_log.ExpenseId = {[expenseId]}
                   ORDER BY audit_log.Stamp ASC)
                  (fn r acc => return (rowFromAuditLog r :: acc))
                  [];
    return (List.rev rows)

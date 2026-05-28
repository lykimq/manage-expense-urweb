open Tables

fun roleMatches expectedRole actualRole =
    expectedRole = actualRole

fun canActOnExpense actorId ownerId =
    actorId <> ownerId

fun roleForUser userId =
    oneOrNoRows (SELECT users.Role
                 FROM users
                 WHERE users.Id = {[userId]})

(* Abort unless the user exists and users.Role equals expectedRole. *)
fun requireRole expectedRole userId =
    roleRowOpt <- roleForUser userId;
    case roleRowOpt of
        None =>
        (Log.warn "policy" ("requireRole rejected (user not found): id=" ^ show userId);
         error <xml><p><b>User not found.</b></p></xml>)
      | Some roleRow =>
        if roleMatches expectedRole roleRow.Users.Role then
            return ()
        else
            (Log.warn "policy"
               ("requireRole rejected: id=" ^ show userId
                ^ " has " ^ roleRow.Users.Role
                ^ ", need " ^ expectedRole);
             error <xml><p><b>You are not allowed to perform this action.</b></p></xml>)

(* Abort when actorId is the expense owner (no self-approval). *)
fun requireNotOwner actorId ownerId =
    if not (canActOnExpense actorId ownerId) then
        (Log.warn "policy"
           ("requireNotOwner rejected: actor and owner both id=" ^ show actorId);
         error <xml><p><b>You cannot act on your own expense.</b></p></xml>)
    else
        return ()

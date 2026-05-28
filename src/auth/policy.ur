open Tables

fun roleForUser userId =
    oneOrNoRows (SELECT users.Role
                 FROM users
                 WHERE users.Id = {[userId]})

fun roleMatches expectedRole actualRoleString =
    case Roles.fromString actualRoleString of
        Some actualRole =>
        (case expectedRole of
             Roles.Employee =>
             (case actualRole of
                  Roles.Employee => True
                | _ => False)
           | Roles.Manager =>
             (case actualRole of
                  Roles.Manager => True
                | _ => False)
           | Roles.Finance =>
             (case actualRole of
                  Roles.Finance => True
                | _ => False))
      | None => False

fun canActOnExpense actorId ownerId =
    actorId <> ownerId

fun rejectRole userId actualRole expectedRole =
    (Log.warn "policy"
       ("requireRole rejected: id=" ^ show userId
        ^ " has " ^ show actualRole
        ^ ", need " ^ show expectedRole);
     error <xml><p><b>You are not allowed to perform this action.</b></p></xml>)

(* Abort unless the user exists and users.Role equals expectedRole. *)
fun requireRole expectedRole userId =
    roleRowOpt <- roleForUser userId;
    case roleRowOpt of
        None =>
        (Log.warn "policy" ("requireRole rejected (user not found): id=" ^ show userId);
         error <xml><p><b>User not found.</b></p></xml>)
      | Some roleRow =>
        case Roles.fromString roleRow.Users.Role of
            None =>
            (Log.warn "policy"
               ("requireRole rejected: id=" ^ show userId
                ^ " has unknown role " ^ roleRow.Users.Role);
             error <xml><p><b>You are not allowed to perform this action.</b></p></xml>)
          | Some actualRole =>
            if roleMatches expectedRole (Roles.toString actualRole) then
                return ()
            else
                rejectRole userId actualRole expectedRole

(* Abort when actorId is the expense owner (no self-approval). *)
fun requireNotOwner actorId ownerId =
    if not (canActOnExpense actorId ownerId) then
        (Log.warn "policy"
           ("requireNotOwner rejected: actor and owner both id=" ^ show actorId);
         error <xml><p><b>You cannot act on your own expense.</b></p></xml>)
    else
        return ()

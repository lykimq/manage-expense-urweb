(* Read user records from the database. *)

open Tables

type user = {Id : int, FullName : string, Role : string, Email : string}

fun rowFromUsers r =
    {Id = r.Users.Id,
     FullName = r.Users.FullName,
     Role = r.Users.Role,
     Email = r.Users.Email}

fun getById id =
    rowOpt <- oneOrNoRows (SELECT users.Id, users.FullName, users.Role, users.Email
                           FROM users
                           WHERE users.Id = {[id]});
    return (case rowOpt of
              None => None
            | Some row => Some (rowFromUsers row))

fun getAll () =
    query (SELECT users.Id, users.FullName, users.Role, users.Email
           FROM users)
          (fn r rows => return (rowFromUsers r :: rows))
          []

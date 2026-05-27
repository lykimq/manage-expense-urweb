open Tables

fun userSummary userId =
    matchedUserOpt <- oneOrNoRows (SELECT users.FullName, users.Role, users.Email
                                   FROM users
                                   WHERE users.Id = {[userId]});
    return (case matchedUserOpt of
               Some matchedUser =>
               <xml>
                 <article>
                   <h2>Welcome, {[matchedUser.Users.FullName]}</h2>
                   <p>You are logged in successfully.</p>
                   <p><b>Role:</b> {[matchedUser.Users.Role]}</p>
                   <p><b>Email:</b> {[matchedUser.Users.Email]}</p>
                 </article>
               </xml>
             | None =>
               <xml>
                 <article>
                   <h2>Logged In User</h2>
                   <p>User details were not found. Please log in again.</p>
                 </article>
               </xml>)

fun page () =
    currentUserOpt <- Session.currentUser ();
    userInfo <- (case currentUserOpt of
                    Some userId => userSummary userId
                  | None => return <xml></xml>);
    Layout.wrap "Expense Management System"
      <xml>
        <section>
          <h1>Welcome to the Expense Management System</h1>
          <p>
            This demo shows a correctness-focused workflow app built with Ur/Web
            and PostgreSQL.
          </p>
        </section>

        {userInfo}
        {Create_expense.content ()}
        {Dashboard.content ()}
      </xml>

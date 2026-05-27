open Tables

(* Prevent caching so browser Back does not reopen stale login page after sign-in. *)
fun setNoCacheHeaders () =
    setHeader (blessResponseHeader "Cache-Control") "no-store, no-cache, must-revalidate, max-age=0";
    setHeader (blessResponseHeader "Pragma") "no-cache";
    setHeader (blessResponseHeader "Expires") "0"

fun loginPage errorMessageOpt =
    setNoCacheHeaders ();
    Layout.wrapNoNav "Login"
      <xml>
        <section>
          <h1>Welcome to the Expense Management System</h1>
          <p>
            This demo shows a correctness-focused workflow app built with Ur/Web
            and PostgreSQL.
          </p>
        </section>

        <article>
          <header>
            <h2>Login</h2>
            <p>Enter your email to continue.</p>
            {case errorMessageOpt of
                 Some errorMessage => <xml><p><b>{[errorMessage]}</b></p></xml>
               | None => <xml></xml>}
            <ul>
              <li>Employee: quyen_ly (at) example.com</li>
              <li>Manager: boss (at) example.com</li>
              <li>Finance: finance (at) example.com</li>
            </ul>
          </header>

          <form>
            <p>
              <label>Email</label>
              <textbox{#Email}/>
            </p>
            <p>
              <submit value="Login" action={signin}/>
            </p>
          </form>
        </article>
      </xml>

and signin r =
    currentUserOpt <- Session.currentUser ();
    case currentUserOpt of
        Some _ => redirect (bless "/Main/home")
      | None =>
        (matchedUserOpt <- oneOrNoRows (SELECT users.Id
                                        FROM users
                                        WHERE users.Email = {[r.Email]});
         case matchedUserOpt of
             Some matchedUser =>
             (Session.login matchedUser.Users.Id;
              redirect (bless "/Main/home"))
           | None => loginPage (Some ("Email '" ^ r.Email ^ "' was not found. Please try again.")))

fun page () =
    currentUserOpt <- Session.currentUser ();
    case currentUserOpt of
        Some _ => redirect (bless "/Main/home")
      | None => loginPage None

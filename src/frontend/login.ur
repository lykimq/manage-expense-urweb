(* Show the login form and handle sign-in by email. *)

fun renderLogin errorMessageOpt =
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
    Session.requireGuest ();
    loginSucceeded <- Session.loginByEmail r.Email;
    if loginSucceeded then
        redirect (bless "/Main/home")
    else
        redirect (bless "/Main/login")

fun page () =
    Session.requireGuest ();
    errorMessageOpt <- Session.consumeLoginError ();
    renderLogin errorMessageOpt

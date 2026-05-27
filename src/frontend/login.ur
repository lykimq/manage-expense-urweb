open Tables

fun invalidEmailPage () =
    Layout.wrap "Login"
      <xml>
        <section>
          <h1>Login</h1>
          <p>Email was not found. Please try again.</p>
          <p><a href="/Main/login">Back to login</a></p>
        </section>
      </xml>

fun signin r =
    uo <- oneOrNoRows (SELECT users.Id
                       FROM users
                       WHERE users.Email = {[r.Email]});
    case uo of
        Some _ => redirect (bless "/Main/home")
      | None => invalidEmailPage ()

fun page () =
    Layout.wrap "Login"
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

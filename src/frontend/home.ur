fun renderUserCard info =
    <xml>
      <article>
        <h2>Welcome, {[info.FullName]}</h2>
        <p>You are logged in successfully.</p>
        <p><b>Role:</b> {[info.Role]}</p>
        <p><b>Email:</b> {[info.Email]}</p>
      </article>
    </xml>

fun page info =
    Layout.wrap "Expense Management System"
      <xml>
        <section>
          <h1>Welcome to the Expense Management System</h1>
          <p>
            This demo shows a correctness-focused workflow app built with Ur/Web
            and PostgreSQL.
          </p>
        </section>

        {renderUserCard info}
        {Create_expense.content ()}
        {Dashboard.content ()}
      </xml>

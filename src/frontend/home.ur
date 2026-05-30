(* Main page after login: greeting and a table of expenses for your role. *)

fun renderUserCard info =
    <xml>
      <article>
        <h2>Welcome, {[info.FullName]}</h2>
        <p><b>Role:</b> {[info.Role]}</p>
        <p><b>Email:</b> {[info.Email]}</p>
      </article>
    </xml>

fun page info =
    userId <- Session.requireUser ();
    workspace <- Dashboard.contentForRole info userId;
    Layout.wrap "Expense Management System"
      <xml>
        <section>
          <h1>Expense Management</h1>
          <p>
            Workflow demo: submit, approve or reject, then mark paid.
            All actions are logged.
          </p>
        </section>
        {renderUserCard info}
        {workspace}
      </xml>

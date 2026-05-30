(* HTML for the expense table and role-specific links; data comes from Dashboard_service. *)

fun expenseRow e =
    <xml>
      <tr>
        <td>{[show e.Id]}</td>
        <td>{[e.Title]}</td>
        <td>{[show e.CreatedAt]}</td>
        <td>{[show e.Amount]}</td>
        <td>{[e.Category]}</td>
        <td>{[e.State]}</td>
        <td><a href={bless ("/Main/detail/" ^ show e.Id)}>View</a></td>
      </tr>
    </xml>

fun expenseRows exps =
    case exps of
        [] => <xml><tr><td colspan={7}><span>No expenses to show.</span></td></tr></xml>
      | _ => List.mapX expenseRow exps

fun panel title tableRows =
    <xml>
      <article>
        <h2>{[title]}</h2>
        {if title = "My Expenses" then
             <xml><p>This table shows expenses submitted under your account.</p></xml>
         else
             <xml/>}
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Title</th>
              <th>Created</th>
              <th>Amount</th>
              <th>Category</th>
              <th>State</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {tableRows}
          </tbody>
        </table>
      </article>
    </xml>

fun roleActions role =
    case role of
        Roles.Employee =>
        <xml>
          <p>
            <a href={bless "/Main/create"}>Submit new expense</a>
          </p>
        </xml>
      | Roles.Manager =>
        <xml>
          <p>
            <a href={bless "/Main/queue"}>Open approval queue</a>
          </p>
        </xml>
      | Roles.Finance =>
        <xml>
          <p>Mark expenses paid from each expense detail page.</p>
        </xml>

fun roleIntro role =
    case role of
        Roles.Employee =>
        <xml>
          <p>Submit a new expense, then track status in the table below.</p>
        </xml>
      | Roles.Manager =>
        <xml>
          <p>Review Submitted expenses below or use the approval queue.</p>
        </xml>
      | Roles.Finance =>
        <xml>
          <p>Approved expenses ready for payment are listed below.</p>
        </xml>

fun contentForRole info userId =
    let
        val roleOpt = Roles.fromString info.Role
    in
        workspace <-
          (case roleOpt of
               Some role => Dashboard_service.loadWorkspace role userId
             | None => return {PanelTitle = "Expenses", Expenses = []});
        return
          <xml>
            <header>
              <h1>Your workspace</h1>
              {case roleOpt of
                   Some role => roleIntro role
                 | None => <xml><p></p></xml>}
              {case roleOpt of
                   Some role => roleActions role
                 | None => <xml><p></p></xml>}
            </header>
            {panel workspace.PanelTitle (expenseRows workspace.Expenses)}
          </xml>
    end

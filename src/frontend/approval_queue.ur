fun queueRow e =
    <xml>
      <tr>
        <td>{[show e.Id]}</td>
        <td>{[e.Title]}</td>
        <td>{[show e.CreatedAt]}</td>
        <td>{[show e.Amount]}</td>
        <td>{[e.Category]}</td>
        <td>{[e.State]}</td>
        <td><a href={bless ("/Main/detail/" ^ show e.Id)}>Open</a></td>
      </tr>
    </xml>

fun content () =
    userInfo <- Session.requireUserInfo ();
    userId <- Session.requireUser ();
    workspace <- Dashboard_service.loadQueueWorkspace userInfo.Role userId;
    return <xml>
      <header>
        <h1>Approval Queue</h1>
        <p>Expenses currently awaiting review or payment action.</p>
      </header>

      <article>
        <h2>{[workspace.PanelTitle]}</h2>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Title</th>
              <th>Created</th>
              <th>Amount</th>
              <th>Category</th>
              <th>State</th>
              <th>Detail</th>
            </tr>
          </thead>
          <tbody>
            {case workspace.Expenses of
                 [] => <xml><tr><td><span>No expenses to show.</span></td></tr></xml>
               | _ => List.mapX queueRow workspace.Expenses}
          </tbody>
        </table>
      </article>
    </xml>

fun page () =
    body <- content ();
    Layout.wrap "Approval Queue" body

(* The read-only parts of the detail page: expense fields and change history. *)

fun showStateLabel state =
    if state = "" then
        "(none)"
    else
        state

fun auditRow item =
    <xml>
      <tr>
        <td>{[show item.Stamp]}</td>
        <td>{[showStateLabel item.OldState]}</td>
        <td>{[showStateLabel item.NewState]}</td>
        <td>{[item.Comment]}</td>
        <td>{[item.ActorName]}</td>
      </tr>
    </xml>

fun auditRows items =
    case items of
        [] => <xml><tr><td><span>No audit entries.</span></td></tr></xml>
      | _ => List.mapX auditRow items

fun pageHeader () =
    <xml>
      <header>
        <h1>Expense Detail</h1>
        <p>
          <a href={bless "/Main/home"}>Back to home</a>
        </p>
      </header>
    </xml>

fun metadataSection detail expenseId =
    <xml>
      <article>
        <h2>Metadata</h2>
        <p>
          This section shows the current snapshot of this expense record.
        </p>
        <table>
          <tr>
            <th>Title</th>
            <td>{[detail.Expense.Title]}</td>
          </tr>
          <tr>
            <th>Created</th>
            <td>{[show detail.Expense.CreatedAt]}</td>
          </tr>
          <tr>
            <th>Amount</th>
            <td>{[show detail.Expense.Amount]}</td>
          </tr>
          <tr>
            <th>Category</th>
            <td>{[detail.Expense.Category]}</td>
          </tr>
          <tr>
            <th>Description</th>
            <td>{[detail.Expense.Description]}</td>
          </tr>
          <tr>
            <th>State</th>
            <td><strong>{[detail.Expense.State]}</strong></td>
          </tr>
          <tr>
            <th>Owner</th>
            <td>{[detail.OwnerName]}</td>
          </tr>
          <tr>
            <th>Expense ID</th>
            <td>{[show expenseId]}</td>
          </tr>
        </table>
      </article>
    </xml>

fun auditSection detail =
    <xml>
      <article>
        <h2>Audit Timeline</h2>
        <p>
          This timeline is for the current expense only. Each row records one
          state change, who made it, and when it happened.
        </p>
        <p>
          Current status: <strong>{[detail.Expense.State]}</strong>
        </p>
        <table>
          <thead>
            <tr>
              <th>Changed At</th>
              <th>From State</th>
              <th>To State</th>
              <th>Comment</th>
              <th>Changed By</th>
            </tr>
          </thead>
          <tbody>
            {auditRows detail.Audit}
          </tbody>
        </table>
      </article>
    </xml>

(* Approval queue placeholder page *)

fun queueRow expenseId title created amount category state =
    <xml>
      <tr>
        <td>{[show expenseId]}</td>
        <td>{[title]}</td>
        <td>{[created]}</td>
        <td>{[show amount]}</td>
        <td>{[category]}</td>
        <td>{[state]}</td>
        <td><a href="/Main/detail">Open</a></td>
      </tr>
    </xml>

fun content () =
    <xml>
      <header>
        <h1>Approval Queue</h1>
        <p>Expenses currently awaiting review or payment action.</p>
      </header>

      <article>
        <h2>Pending Actions</h2>
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
            {queueRow 3 "Office supplies" "2026-05-25" 120.00 "Office" "Submitted"}
            {queueRow 4 "Laptop" "2026-05-20" 1200.00 "Equipment" "Approved"}
          </tbody>
        </table>
      </article>
    </xml>

fun page () =
    Layout.wrap "Approval Queue" (content ())

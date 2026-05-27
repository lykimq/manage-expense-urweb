(* Expense detail placeholder page *)

fun content expenseId =
    <xml>
      <header>
        <h1>Expense Detail</h1>
        <p>Placeholder detail page for expense {[show expenseId]}.</p>
      </header>

      <article>
        <h2>Metadata</h2>
        <table>
          <tr>
            <th>Title</th>
            <td>Lunch with client</td>
          </tr>
          <tr>
            <th>Created</th>
            <td>2026-05-27</td>
          </tr>
          <tr>
            <th>Amount</th>
            <td>42.50</td>
          </tr>
          <tr>
            <th>Category</th>
            <td>Travel</td>
          </tr>
          <tr>
            <th>Description</th>
            <td>Client lunch after review meeting.</td>
          </tr>
          <tr>
            <th>State</th>
            <td><strong>Submitted</strong></td>
          </tr>
          <tr>
            <th>Owner</th>
            <td>Employee Demo</td>
          </tr>
          <tr>
            <th>Expense ID</th>
            <td>{[show expenseId]}</td>
          </tr>
        </table>
      </article>

      <article>
        <h2>Audit Timeline</h2>
        <table>
          <thead>
            <tr>
              <th>Stamp</th>
              <th>OldState</th>
              <th>NewState</th>
              <th>Comment</th>
              <th>Actor</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>2026-05-27 09:10</td>
              <td>Draft</td>
              <td>Draft</td>
              <td>Initial creation</td>
              <td>Employee Demo</td>
            </tr>
            <tr>
              <td>2026-05-27 09:22</td>
              <td>Draft</td>
              <td>Submitted</td>
              <td>Submitted for manager review</td>
              <td>Employee Demo</td>
            </tr>
          </tbody>
        </table>
      </article>

      <article>
        <h2>Actions</h2>
        <p>Action buttons are not implemented yet.</p>
      </article>
    </xml>

fun page expenseId =
    Layout.wrap "Expense Detail" (content expenseId)

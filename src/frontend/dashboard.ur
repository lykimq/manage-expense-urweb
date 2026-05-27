(* Dashboard page *)

fun panel title rows =
    <xml>
      <article>
        <h2>{[title]}</h2>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Title</th>
              <th>Created</th>
              <th>Amount</th>
              <th>Category</th>
              <th>State</th>
            </tr>
          </thead>
          <tbody>
            {rows}
          </tbody>
        </table>
      </article>
    </xml>

fun row id title created amount category state =
    <xml>
      <tr>
        <td>{[show id]}</td>
        <td>{[title]}</td>
        <td>{[created]}</td>
        <td>{[show amount]}</td>
        <td>{[category]}</td>
        <td>{[state]}</td>
      </tr>
    </xml>

fun content () =
    <xml>
      <header>
        <h1>Dashboard</h1>
        <p>Overview of all expenses</p>
      </header>

      {panel "My Expenses"
         <xml>
           {row 1 "Lunch with client" "2026-05-27" 42.50 "Travel" "Draft"}
           {row 2 "Train tickets" "2026-05-26" 100.00 "Travel" "Submitted"}
         </xml>}

      {panel "Pending Approvals"
         <xml>
           {row 3 "Office supplies" "2026-05-25" 120.00 "Office" "Submitted"}
         </xml>}

      {panel "Pending Payments"
         <xml>
           {row 4 "Laptop" "2026-05-20" 1200.00 "Equipment" "Approved"}
         </xml>}
    </xml>

fun page () =
    Layout.wrap "Dashboard" (content ())

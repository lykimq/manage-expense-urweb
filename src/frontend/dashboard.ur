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
              <th>Amount</th>
              <th>State</th>
            </tr>
          </thead>
          <tbody>
            {rows}
          </tbody>
        </table>
      </article>
    </xml>

fun row id title amount state =
    <xml>
      <tr>
        <td>{[show id]}</td>
        <td>{[title]}</td>
        <td>{[show amount]}</td>
        <td>{[state]}</td>
      </tr>
    </xml>

fun page () =
    Layout.wrap "Dashboard"
      <xml>
        <header>
          <h1>Dashboard</h1>
          <p>Overview of all expenses</p>
        </header>

        {panel "My Expenses"
           <xml>
             {row 1 "Lunch with client" 42.50 "Draft"}
             {row 2 "Train tickets" 100.00 "Submitted"}
           </xml>}

        {panel "Pending Approvals"
           <xml>
             {row 3 "Office supplies" 120.00 "Submitted"}
           </xml>}

        {panel "Pending Payments"
           <xml>
             {row 4 "Laptop" 1200.00 "Approved"}
           </xml>}
      </xml>

(* Create a new expense *)

fun hasRequiredFields r =
    r.Title <> ""
    && r.Amount <> ""
    && r.Category <> ""

fun missingFieldsPage () =
    Layout.wrap "Create Expense"
      <xml>
        <header>
          <h1>Create Expense</h1>
          <p>Please fill all required fields before continuing.</p>
        </header>
        <article>
          <p>
            Required fields are Title, Amount, and Category.
          </p>
          <p>
            <a href="/Main/home">Back to Home</a>
          </p>
        </article>
      </xml>

fun formAction r =
    userId <- Session.requireUser ();
    Policy.requireRole "Employee" userId;
    if not (hasRequiredFields r) then
        missingFieldsPage ()
    else
        expenseId <- Expense_service.create userId
          {Title = r.Title,
           Amount = r.Amount,
           Category = r.Category,
           Description = r.Description};
        Log.info "create_expense" ("created expense_id=" ^ show expenseId);
        redirect (bless "/Main/home")

fun content () =
    <xml>
      <header>
        <h1>Create Expense</h1>
        <p>Fields marked with * are required.</p>
      </header>

      <article>
        <h2>Expense Details</h2>
        <p>Fill in the fields below and submit for approval.</p>
        <form>
          <table>
            <tr>
              <th><label>Title *</label></th>
              <td><textbox{#Title}/></td>
            </tr>
            <tr>
              <th><label>Amount *</label></th>
              <td><textbox{#Amount}/></td>
            </tr>
            <tr>
              <th><label>Category *</label></th>
              <td><textbox{#Category}/></td>
            </tr>
            <tr>
              <th><label>Description</label></th>
              <td><textarea{#Description}/></td>
            </tr>
          </table>
          <p>
            <submit value="Submit for Approval" action={formAction}/>
          </p>
        </form>
      </article>
    </xml>

fun page () =
    Layout.wrap "Create Expense" (content ())

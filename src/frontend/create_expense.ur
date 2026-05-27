(* Create a new expense *)

fun hasRequiredFields r =
    r.Title <> ""
    && r.Date <> ""
    && r.Amount <> ""
    && r.Category <> ""
    && (case r.Action of
            None => False
          | Some _ => True)

fun missingFieldsPage () =
    Layout.wrap "Create Expense"
      <xml>
        <header>
          <h1>Create Expense</h1>
          <p>Please fill all required fields before continuing.</p>
        </header>
        <article>
          <p>
            Required fields are Title, Date, Amount, Category, and Action.
          </p>
          <p>
            <a href="/Main/home">Back to Home</a>
          </p>
        </article>
      </xml>

fun formAction r =
    let
        val _ = r.Description
    in
        if hasRequiredFields r then
            redirect (bless "/Main/home")
        else
            missingFieldsPage ()
    end

fun content () =
    <xml>
      <header>
        <h1>Create Expense</h1>
        <p>Fields marked with * are required.</p>
      </header>

      <article>
        <h2>Expense Details</h2>
        <p>Fill in fields below, choose action, and continue</p>
        <form>
          <table>
            <tr>
              <th><label>Title *</label></th>
              <td><textbox{#Title}/></td>
            </tr>
            <tr>
              <th><label>Date *</label></th>
              <td><textbox{#Date}/></td>
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
            <label>Action</label>
            <radio{#Action}>
              <radioOption value="draft"/> Save Draft
              <radioOption value="submit"/> Submit for Approval
            </radio>
          </p>
          <p>
            <submit value="Continue" action={formAction}/>
          </p>
        </form>
      </article>
    </xml>

fun page () =
    Layout.wrap "Create Expense" (content ())
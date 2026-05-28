(* Create a new expense *)

fun hasRequiredFields r =
    r.Title <> ""
    && r.Amount <> ""
    && r.Category <> ""

fun formAction r =
    userId <- Session.requireUser ();
    Policy.requireRole Roles.Employee userId;
    if not (hasRequiredFields r) then
        Layout.wrap "Create Expense" (renderForm r True)
    else
        expenseId <- Expense_service.create userId
          {Title = r.Title,
           Amount = r.Amount,
           Category = r.Category,
           Description = r.Description};
        Log.info "create_expense" ("created expense_id=" ^ show expenseId);
        redirect (bless "/Main/home")

and renderForm r showRequiredMessage =
    <xml>
      <header>
        <h1>Create Expense</h1>
        <p>Fields marked with * are required.</p>
      </header>

      <article>
        <h2>Expense Details</h2>
        <p>Fill in the fields below and submit for approval.</p>
        {if showRequiredMessage then
             <xml>
               <p style="color:#b91c1c; background:#fee2e2; border:1px solid #fecaca; border-radius:8px; padding:10px 12px;">
                 <b>Please fill all required fields before continuing.</b>
               </p>
             </xml>
         else
             <xml/>}
        <form>
          <table>
            <tr>
              <th>
                {if showRequiredMessage && r.Title = "" then
                     <xml><label style="color:#b91c1c;">Title * (required)</label></xml>
                 else
                     <xml><label>Title *</label></xml>}
              </th>
              <td><textbox{#Title} value={r.Title}/></td>
            </tr>
            <tr>
              <th>
                {if showRequiredMessage && r.Amount = "" then
                     <xml><label style="color:#b91c1c;">Amount * (required)</label></xml>
                 else
                     <xml><label>Amount *</label></xml>}
              </th>
              <td><textbox{#Amount} value={r.Amount}/></td>
            </tr>
            <tr>
              <th>
                {if showRequiredMessage && r.Category = "" then
                     <xml><label style="color:#b91c1c;">Category * (required)</label></xml>
                 else
                     <xml><label>Category *</label></xml>}
              </th>
              <td><textbox{#Category} value={r.Category}/></td>
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

fun content () =
    renderForm {Title = "", Amount = "", Category = "", Description = ""} False

fun page () =
    Layout.wrap "Create Expense" (content ())

(* Create a new expense *)

fun hasRequiredFields r =
    r.Title <> ""
    && r.Amount <> ""
    && r.Category <> ""

(* RPC demo: session + delegate to Expense_service.checkAmount. *)
fun checkAmountRpc (amount : string) : transaction (bool * string) =
    userId <- Session.requireUser ();
    Expense_service.checkAmount userId amount

fun amountCheckFeedbackBody okSrc msgSrc =
    ok <- signal okSrc;
    msg <- signal msgSrc;
    return <xml>
             {case msg of
                  "" => <xml/>
                | _ =>
                  if ok then
                      <xml><p role="amount-check-ok">{[msg]}</p></xml>
                  else
                      <xml><p role="amount-check-err">{[msg]}</p></xml>}
           </xml>

fun checkAmountClick amountSrc okSrc msgSrc () =
    v <- get amountSrc;
    (ok, msg) <- rpc (checkAmountRpc v);
    set okSrc ok;
    set msgSrc msg

fun validationBanner showRequiredMessage showInvalidAmountMessage =
    if showRequiredMessage then
        <xml>
          <p role="form-validation-err">
            <b>Please fill all required fields before continuing.</b>
          </p>
        </xml>
    else if showInvalidAmountMessage then
        <xml>
          <p role="form-validation-err">
            <b>Amount must be a valid number.</b>
          </p>
        </xml>
    else
        <xml/>

fun amountCheckSection amountSrc okSrc msgSrc =
    <xml>
      <div>
        <p>
          <button value="Check amount"
                  onclick={fn _ => checkAmountClick amountSrc okSrc msgSrc ()}/>
        </p>
        <dyn signal={amountCheckFeedbackBody okSrc msgSrc}/>
        <p>
          Demo: Check amount calls the server via Ur/Web RPC using the same
          parser as submit, so you can confirm the value before sending the form.
          Submit runs the same validation again on the server.
        </p>
      </div>
    </xml>

fun createExpenseHeader () =
    <xml>
      <header>
        <h1>Create Expense</h1>
        <p>Fields marked with * are required.</p>
      </header>
    </xml>

fun renderForm amountSrc okSrc msgSrc r showRequiredMessage showInvalidAmountMessage =
    <xml>
      {createExpenseHeader ()}
      <article>
        <h2>Expense Details</h2>
        <p>Fill in the fields below and submit for approval.</p>
        {validationBanner showRequiredMessage showInvalidAmountMessage}
        <form>
          <table>
            <tr>
              <th>
                {if showRequiredMessage && r.Title = "" then
                     <xml>
                       <span role="required-field-label">
                         <label>Title * (required)</label>
                       </span>
                     </xml>
                 else
                     <xml><label>Title *</label></xml>}
              </th>
              <td><textbox{#Title} value={r.Title}/></td>
            </tr>
            <tr>
              <th>
                {if showRequiredMessage && r.Amount = "" then
                     <xml>
                       <span role="required-field-label">
                         <label>Amount * (required)</label>
                       </span>
                     </xml>
                 else if showInvalidAmountMessage then
                     <xml>
                       <span role="invalid-amount-label">
                         <label>Amount * (invalid)</label>
                       </span>
                     </xml>
                 else
                     <xml><label>Amount *</label></xml>}
              </th>
              <td>
                <textbox{#Amount} source={amountSrc} value={r.Amount}/>
              </td>
            </tr>
            <tr>
              <th>
                {if showRequiredMessage && r.Category = "" then
                     <xml>
                       <span role="required-field-label">
                         <label>Category * (required)</label>
                       </span>
                     </xml>
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
        {amountCheckSection amountSrc okSrc msgSrc}
      </article>
    </xml>

and formAction r =
    userId <- Session.requireUser ();
    Policy.requireRole Roles.Employee userId;
    if not (hasRequiredFields r) then
        amountSrc <- source r.Amount;
        okSrc <- source False;
        msgSrc <- source "";
        Layout.wrap "Create Expense" (renderForm amountSrc okSrc msgSrc r True False)
    else
        case Expense_service.parseAmountValue r.Amount of
            None =>
            amountSrc <- source r.Amount;
            okSrc <- source False;
            msgSrc <- source "";
            Layout.wrap "Create Expense"
              (renderForm amountSrc okSrc msgSrc r False True)
          | Some _ =>
            expenseId <- Expense_service.create userId
              {Title = r.Title,
               Amount = r.Amount,
               Category = r.Category,
               Description = r.Description};
            Log.info "create_expense" ("created expense_id=" ^ show expenseId);
            redirect (bless "/Main/home")

fun content amountSrc okSrc msgSrc =
    renderForm amountSrc okSrc msgSrc
      {Title = "", Amount = "", Category = "", Description = ""}
      False
      False

fun page () : transaction page =
    amountSrc <- source "";
    okSrc <- source False;
    msgSrc <- source "";
    Layout.wrap "Create Expense" (content amountSrc okSrc msgSrc)

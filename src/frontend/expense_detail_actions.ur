fun detailUrl expenseId =
    bless ("/Main/detail/" ^ show expenseId)

fun managerAction expenseId r =
    userId <- Session.requireUser ();
    case r.Decision of
        Some "Approve" =>
        Expense_service.approve userId expenseId r.Comment;
        redirect (detailUrl expenseId)
      | Some "Reject" =>
        Expense_service.reject userId expenseId r.Comment;
        redirect (detailUrl expenseId)
      | None =>
        error <xml><p><b>Choose Approve or Reject.</b></p></xml>
      | Some _ =>
        error <xml><p><b>Invalid action.</b></p></xml>

fun payForm expenseId () =
    userId <- Session.requireUser ();
    Expense_service.pay userId expenseId;
    redirect (detailUrl expenseId)

fun managerForms expenseId =
    <xml>
      <form>
        <p>
          <label>Comment</label>
          <textarea{#Comment}/>
        </p>
        <p>
          <radio{#Decision}>
            <li><radioOption value="Approve"/> Approve</li>
            <li><radioOption value="Reject"/> Reject</li>
          </radio>
        </p>
        <p>
          <submit value="Apply" action={managerAction expenseId}/>
        </p>
      </form>
    </xml>

fun financeForm expenseId =
    <xml>
      <form>
        <p>
          <submit value="Mark paid" action={payForm expenseId}/>
        </p>
      </form>
    </xml>

fun actionsSection userId userRole expense =
    case State.fromString expense.State of
        None => return <xml><p>Actions are not available for an invalid state.</p></xml>
      | Some state =>
        if userRole = "Manager"
           && userId <> expense.OwnerId
           && Transition.canApprove state then
            return (managerForms expense.Id)
        else if userRole = "Finance" && Transition.canPay state then
            return (financeForm expense.Id)
        else
            return <xml><p>No actions available for your role and this expense state.</p></xml>

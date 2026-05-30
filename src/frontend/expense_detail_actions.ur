(* Approve/reject form for managers and Mark paid button for finance. *)

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
      | _ =>
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
          <label>Decision</label>
          <radio{#Decision}>
            <span><radioOption value="Approve"/> Approve</span>
            <span><radioOption value="Reject"/> Reject</span>
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
        case Roles.fromString userRole of
            Some Roles.Manager =>
            if userId <> expense.OwnerId
               && Transition.canApprove state then
                return (managerForms expense.Id)
            else
                return <xml><p>No actions available for your role and this expense state.</p></xml>
          | Some Roles.Finance =>
            if Transition.canPay state then
                return (financeForm expense.Id)
            else
                return <xml><p>No actions available for your role and this expense state.</p></xml>
          | _ =>
            return <xml><p>No actions available for your role and this expense state.</p></xml>

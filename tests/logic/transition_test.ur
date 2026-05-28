val groupName = "transition"

(* canApprove truth table: only Submitted is allowed. *)
val canApproveSubmittedTrue =
    Test_harness.mkResult "canApprove allows Submitted"
        (Transition.canApprove State.Submitted)

val canApproveApprovedFalse =
    Test_harness.mkResult "canApprove rejects Approved"
        (not (Transition.canApprove State.Approved))

val canApproveRejectedFalse =
    Test_harness.mkResult "canApprove rejects Rejected"
        (not (Transition.canApprove State.Rejected))

val canApprovePaidFalse =
    Test_harness.mkResult "canApprove rejects Paid"
        (not (Transition.canApprove State.Paid))

(* canReject truth table: only Submitted is allowed. *)
val canRejectSubmittedTrue =
    Test_harness.mkResult "canReject allows Submitted"
        (Transition.canReject State.Submitted)

val canRejectApprovedFalse =
    Test_harness.mkResult "canReject rejects Approved"
        (not (Transition.canReject State.Approved))

val canRejectRejectedFalse =
    Test_harness.mkResult "canReject rejects Rejected"
        (not (Transition.canReject State.Rejected))

val canRejectPaidFalse =
    Test_harness.mkResult "canReject rejects Paid"
        (not (Transition.canReject State.Paid))

(* canPay truth table: only Approved is allowed. *)
val canPaySubmittedFalse =
    Test_harness.mkResult "canPay rejects Submitted"
        (not (Transition.canPay State.Submitted))

val canPayApprovedTrue =
    Test_harness.mkResult "canPay allows Approved"
        (Transition.canPay State.Approved)

val canPayRejectedFalse =
    Test_harness.mkResult "canPay rejects Rejected"
        (not (Transition.canPay State.Rejected))

val canPayPaidFalse =
    Test_harness.mkResult "canPay rejects Paid"
        (not (Transition.canPay State.Paid))

(* Invariant: Rejected and Paid are terminal states (no action is allowed). *)
fun isTerminal (s : State.expense_state) : bool =
    not (Transition.canApprove s)
    && not (Transition.canReject s)
    && not (Transition.canPay s)

val rejectedIsTerminal =
    Test_harness.mkResult "Rejected is a terminal state"
        (isTerminal State.Rejected)

val paidIsTerminal =
    Test_harness.mkResult "Paid is a terminal state"
        (isTerminal State.Paid)

(* Invariant: canApprove and canReject share the same source state. *)
fun reviewActionsAlign (s : State.expense_state) : bool =
    Transition.canApprove s = Transition.canReject s

val approveRejectShareSource =
    Test_harness.mkResult "approve and reject share the same source state"
        (reviewActionsAlign State.Submitted
         && reviewActionsAlign State.Approved
         && reviewActionsAlign State.Rejected
         && reviewActionsAlign State.Paid)

(* Invariant: payment is mutually exclusive with manager review actions. *)
fun payMutexWithReview (s : State.expense_state) : bool =
    if Transition.canPay s then
        not (Transition.canApprove s) && not (Transition.canReject s)
    else
        True

val payMutex =
    Test_harness.mkResult "pay is mutually exclusive with review actions"
        (payMutexWithReview State.Submitted
         && payMutexWithReview State.Approved
         && payMutexWithReview State.Rejected
         && payMutexWithReview State.Paid)

(* Invariant: number of allowed actions matches the workflow shape. *)
fun actionCount (s : State.expense_state) : int =
    (if Transition.canApprove s then 1 else 0)
    + (if Transition.canReject s then 1 else 0)
    + (if Transition.canPay s then 1 else 0)

val submittedHasTwoActions =
    Test_harness.mkResult "Submitted has two allowed actions"
        (actionCount State.Submitted = 2)

val approvedHasOneAction =
    Test_harness.mkResult "Approved has one allowed action"
        (actionCount State.Approved = 1)

val rejectedHasZeroActions =
    Test_harness.mkResult "Rejected has zero allowed actions"
        (actionCount State.Rejected = 0)

val paidHasZeroActions =
    Test_harness.mkResult "Paid has zero allowed actions"
        (actionCount State.Paid = 0)

val results : list Test_harness.test_result =
    canApproveSubmittedTrue ::
    canApproveApprovedFalse ::
    canApproveRejectedFalse ::
    canApprovePaidFalse ::
    canRejectSubmittedTrue ::
    canRejectApprovedFalse ::
    canRejectRejectedFalse ::
    canRejectPaidFalse ::
    canPaySubmittedFalse ::
    canPayApprovedTrue ::
    canPayRejectedFalse ::
    canPayPaidFalse ::
    rejectedIsTerminal ::
    paidIsTerminal ::
    approveRejectShareSource ::
    payMutex ::
    submittedHasTwoActions ::
    approvedHasOneAction ::
    rejectedHasZeroActions ::
    paidHasZeroActions ::
    []

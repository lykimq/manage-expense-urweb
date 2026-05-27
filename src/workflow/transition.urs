(** Which state transitions are allowed (service layer enforces these). *)

val canApprove : State.expense_state -> bool
val canReject : State.expense_state -> bool
val canPay : State.expense_state -> bool

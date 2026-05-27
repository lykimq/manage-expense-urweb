(** Valid transition checks per expense_state. *)

(* Draft -> Submitted *)
val canSubmit : State.expense_state -> bool

(* Submitted -> Approved *)
val canApprove : State.expense_state -> bool

(* Submitted -> Rejected *)
val canReject : State.expense_state -> bool

(* Approved -> Paid *)
val canPay : State.expense_state -> bool

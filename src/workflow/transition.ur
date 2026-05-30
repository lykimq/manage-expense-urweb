(* Decide whether approve, reject, or pay is allowed in the current stage. *)

fun canApprove st =
    case st of
        State.Submitted => True
      | _ => False

fun canReject st =
    case st of
        State.Submitted => True
      | _ => False

fun canPay st =
    case st of
        State.Approved => True
      | _ => False

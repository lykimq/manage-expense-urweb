fun canSubmit st =
    case st of
        State.Draft => True
      | _ => False

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

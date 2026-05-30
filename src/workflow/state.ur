(* The four stages an expense can be in: Submitted, Approved, Rejected, Paid. *)

datatype expense_state = Submitted | Approved | Rejected | Paid

fun stateToString state =
    case state of
        Submitted => "Submitted"
      | Approved => "Approved"
      | Rejected => "Rejected"
      | Paid => "Paid"

fun fromString s =
    case s of
        "Submitted" => Some Submitted
      | "Approved" => Some Approved
      | "Rejected" => Some Rejected
      | "Paid" => Some Paid
      | _ => None

val show_expense_state : show expense_state =
    mkShow stateToString

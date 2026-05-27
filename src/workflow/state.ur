datatype expense_state = Submitted | Approved | Rejected | Paid

fun toString state =
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

(* show instance used to render expense_state as text *)
val show_expense_state : show expense_state =
    mkShow toString

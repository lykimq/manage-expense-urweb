datatype expense_state = Draft | Submitted | Approved | Rejected | Paid

fun toString state =
    case state of
        Draft => "Draft"
      | Submitted => "Submitted"
      | Approved => "Approved"
      | Rejected => "Rejected"
      | Paid => "Paid"

fun fromString s =
    case s of
        "Draft" => Some Draft
      | "Submitted" => Some Submitted
      | "Approved" => Some Approved
      | "Rejected" => Some Rejected
      | "Paid" => Some Paid
      | _ => None

(* show instance used to render expense_state as text *)
val show_expense_state : show expense_state =
    mkShow toString

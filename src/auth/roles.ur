(* The three user types in this app and helpers to read and write them as text. *)

datatype role = Employee | Manager | Finance

fun toString r =
    case r of
        Employee => "Employee"
      | Manager => "Manager"
      | Finance => "Finance"

fun fromString s =
    case s of
        "Employee" => Some Employee
      | "Manager" => Some Manager
      | "Finance" => Some Finance
      | _ => None

val show_role : show role =
    mkShow toString

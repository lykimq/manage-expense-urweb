(* Server console logging with a fixed level + component prefix. *)

fun write level component message =
    debug (level ^ " [" ^ component ^ "] " ^ message)

fun debug component message =
    write "DEBUG" component message

fun info component message =
    write "INFO" component message

fun warn component message =
    write "WARN" component message

fun error component message =
    write "ERROR" component message

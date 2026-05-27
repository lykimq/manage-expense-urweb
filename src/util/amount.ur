fun parseFloat s : option float =
    if strlen s = 0 then
        (None : option float)
    else
        case read s : option float of
            None => (None : option float)
          | Some x => Some x

val amountToString = show

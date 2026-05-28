type test_result =
    {Description : string,
     Passed : bool}

fun mkResult (description : string) (passed : bool) : test_result =
    {Description = description,
     Passed = passed}

fun statusOf (passed : bool) : string =
    if passed then "PASS" else "FAIL"

fun resultLine (group : string) (r : test_result) : string =
    "TEST " ^ group ^ ": " ^ r.Description ^ " " ^ statusOf r.Passed

fun formatGroup (group : string) (results : list test_result) : string =
    case results of
        [] => ""
      | r :: rest => resultLine group r ^ "\n" ^ formatGroup group rest

fun allPassed (results : list test_result) : bool =
    case results of
        [] => True
      | r :: rest =>
        if r.Passed then allPassed rest else False

fun countPassed (results : list test_result) : int =
    case results of
        [] => 0
      | r :: rest =>
        (if r.Passed then 1 else 0) + countPassed rest

fun countTotal (results : list test_result) : int =
    case results of
        [] => 0
      | _ :: rest => 1 + countTotal rest

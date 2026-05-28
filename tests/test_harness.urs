(* Lightweight assertion infrastructure for pure logic tests.
   Each test produces a {Description, Passed} record; modules collect them
   in a list. The main runner formats the lines and computes counts. *)

type test_result =
    {Description : string,
     Passed : bool}

val mkResult : string -> bool -> test_result

val statusOf : bool -> string

val resultLine : string -> test_result -> string

val formatGroup : string -> list test_result -> string

val allPassed : list test_result -> bool

val countPassed : list test_result -> int

val countTotal : list test_result -> int

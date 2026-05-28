(** Tests for Policy module behavior. *)

val groupName : string
val runAll : unit -> transaction (list Test_harness.test_result)

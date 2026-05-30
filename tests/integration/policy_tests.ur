(* Integration tests for role checks and no-self-approval rules against seeded users. *)

val groupName = "policy"

(* Exercise requireRole and requireNotOwner with real database users. *)
fun runAll () : transaction (list Test_harness.test_result) =
    _ <- Policy.requireRole Roles.Employee 1;
    _ <- Policy.requireRole Roles.Manager 2;
    _ <- Policy.requireRole Roles.Finance 3;
    _ <- Policy.requireNotOwner 2 1;
    _ <- Policy.requireNotOwner 3 1;
    return (Test_harness.mkResult "requireRole accepts seeded Employee user" True ::
            Test_harness.mkResult "requireRole accepts seeded Manager user" True ::
            Test_harness.mkResult "requireRole accepts seeded Finance user" True ::
            Test_harness.mkResult "roleMatches rejects Manager expected vs Finance actual"
              (not (Policy.roleMatches Roles.Manager "Finance")) ::
            Test_harness.mkResult "roleMatches rejects unknown role string"
              (not (Policy.roleMatches Roles.Manager "UnknownRole")) ::
            Test_harness.mkResult "canActOnExpense rejects self ownership"
              (not (Policy.canActOnExpense 7 7)) ::
            Test_harness.mkResult "requireNotOwner allows manager on employee expense" True ::
            Test_harness.mkResult "requireNotOwner allows finance on employee expense" True ::
            [])

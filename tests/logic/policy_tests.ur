val groupName = "policy"

fun roleMatches expectedRole actualRole =
    expectedRole = actualRole

fun canActOnExpense ids =
    ids.ActorId <> ids.OwnerId

val roleMatchesExact =
    Test_harness.mkResult "matching role names are accepted"
        (roleMatches "Manager" "Manager")

val roleMismatchDenied =
    Test_harness.mkResult "different role names are rejected"
        (not (roleMatches "Manager" "Employee"))

val roleCaseSensitive =
    Test_harness.mkResult "role matching is case sensitive"
        (not (roleMatches "manager" "Manager"))

val roleEmptyOnlyMatchesEmpty =
    Test_harness.mkResult "empty role only matches empty role"
        (roleMatches "" ""
         && not (roleMatches "" "Finance")
         && not (roleMatches "Finance" ""))

val notOwnerAllowed =
    Test_harness.mkResult "actor can act when actor and owner are different"
        (canActOnExpense {ActorId = 2, OwnerId = 1})

val ownerDenied =
    Test_harness.mkResult "actor cannot act on own expense"
        (not (canActOnExpense {ActorId = 7, OwnerId = 7}))

val canActSymmetricWhenDifferent =
    Test_harness.mkResult "non-owner check is symmetric for distinct ids"
        (canActOnExpense {ActorId = 3, OwnerId = 9}
         && canActOnExpense {ActorId = 9, OwnerId = 3})

val results : list Test_harness.test_result =
    roleMatchesExact ::
    roleMismatchDenied ::
    roleCaseSensitive ::
    roleEmptyOnlyMatchesEmpty ::
    notOwnerAllowed ::
    ownerDenied ::
    canActSymmetricWhenDifferent ::
    []

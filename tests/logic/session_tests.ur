val groupName = "session"

fun hasCurrentUser currentUserOpt =
    case currentUserOpt of
        Some _ => True
      | None => False

fun shouldRedirectRequireUser currentUserOpt =
    not (hasCurrentUser currentUserOpt)

fun shouldRedirectRequireGuest currentUserOpt =
    hasCurrentUser currentUserOpt

fun shouldRedirectRequireUserInfo hasUserInfo =
    not hasUserInfo

val hasCurrentUserSome =
    Test_harness.mkResult "hasCurrentUser returns true for Some user"
        (hasCurrentUser (Some 1))

val hasCurrentUserNone =
    Test_harness.mkResult "hasCurrentUser returns false for None"
        (not (hasCurrentUser None))

val requireUserRedirectsWithoutSession =
    Test_harness.mkResult "requireUser redirects when session is missing"
        (shouldRedirectRequireUser None)

val requireUserAllowsWithSession =
    Test_harness.mkResult "requireUser does not redirect when session exists"
        (not (shouldRedirectRequireUser (Some 42)))

val requireGuestAllowsWithoutSession =
    Test_harness.mkResult "requireGuest does not redirect when session is missing"
        (not (shouldRedirectRequireGuest None))

val requireGuestRedirectsWithSession =
    Test_harness.mkResult "requireGuest redirects when session exists"
        (shouldRedirectRequireGuest (Some 42))

val requireGuestOpposesRequireUser =
    Test_harness.mkResult "requireGuest redirect decision is opposite of requireUser"
        (shouldRedirectRequireGuest None
            = not (shouldRedirectRequireUser None)
         && shouldRedirectRequireGuest (Some 3)
            = not (shouldRedirectRequireUser (Some 3)))

val requireUserInfoRedirectWhenMissing =
    Test_harness.mkResult "requireUserInfo redirects when user info is missing"
        (shouldRedirectRequireUserInfo False)

val requireUserInfoAllowsWhenPresent =
    Test_harness.mkResult "requireUserInfo does not redirect when user info exists"
        (not (shouldRedirectRequireUserInfo True))

val results : list Test_harness.test_result =
    hasCurrentUserSome ::
    hasCurrentUserNone ::
    requireUserRedirectsWithoutSession ::
    requireUserAllowsWithSession ::
    requireGuestAllowsWithoutSession ::
    requireGuestRedirectsWithSession ::
    requireGuestOpposesRequireUser ::
    requireUserInfoRedirectWhenMissing ::
    requireUserInfoAllowsWhenPresent ::
    []

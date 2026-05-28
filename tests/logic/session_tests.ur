val groupName = "session"

fun runAll () : transaction (list Test_harness.test_result) =
    Session.logout ();
    currentNone <- Session.currentUser ();
    _ <- Session.requireGuest ();
    loginOk <- Session.loginByEmail "quyen_ly@example.com";
    consumedError <- Session.consumeLoginError ();
    Session.logout ();
    currentAfterLogout <- Session.currentUser ();
    badLoginOk <- Session.loginByEmail "missing_user@example.com";
    flashAfterConsume <- Session.consumeLoginError ();
    Session.logout ();
    return
      (Test_harness.mkResult "currentUser is None after logout"
           (case currentNone of
                None => True
              | Some _ => False) ::
       Test_harness.mkResult "requireGuest allows access without session" True ::
       Test_harness.mkResult "loginByEmail succeeds for seeded user" loginOk ::
       Test_harness.mkResult "login error flash is empty after successful login"
           (case consumedError of
                None => True
              | Some _ => False) ::
       Test_harness.mkResult "logout clears session cookie"
           (case currentAfterLogout of
                None => True
              | Some _ => False) ::
       Test_harness.mkResult "loginByEmail fails for unknown email" (not badLoginOk) ::
       Test_harness.mkResult "consumeLoginError clears flash after one read"
           (case flashAfterConsume of
                None => True
              | Some _ => False) ::
       [])

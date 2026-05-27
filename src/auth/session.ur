cookie user_session : {UserId : int}

fun login userId =
    setCookie user_session {Value = {UserId = userId},
                            Expires = None,
                            Secure = False}

fun logout () =
    clearCookie user_session

fun currentUser () =
    sessionCookieOpt <- getCookie user_session;
    return (case sessionCookieOpt of
              Some s => Some s.UserId
            | None => None)

fun requireUser () =
    currentUserOpt <- currentUser ();
    case currentUserOpt of
        Some id => return id
      | None => error <xml>Please log in</xml>

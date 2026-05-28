open Tables

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

(* Signed-in user id. *)
cookie user_session : {UserId : int}

(* One-shot login error message after a failed sign-in redirect. *)
cookie login_error : string

(* Tell the browser not to cache the page (avoids stale UI on Back). *)
fun setNoCacheHeaders () =
    setHeader (blessResponseHeader "Cache-Control") "no-store, no-cache, must-revalidate, max-age=0";
    setHeader (blessResponseHeader "Pragma") "no-cache";
    setHeader (blessResponseHeader "Expires") "0"

fun login userId =
    Log.info "session" ("login user_id=" ^ show userId);
    setCookie user_session {Value = {UserId = userId},
                            Expires = None,
                            Secure = False}

(* Drop session and any flash error. *)
fun logout () =
    Log.info "session" "logout";
    clearCookie user_session;
    clearCookie login_error

fun currentUser () =
    sessionCookieOpt <- getCookie user_session;
    return (case sessionCookieOpt of
              Some s => Some s.UserId
            | None => None)

fun currentUserInfo () =
    currentUserOpt <- currentUser ();
    case currentUserOpt of
        None => return None
      | Some userId =>
        userRowOpt <- oneOrNoRows (SELECT users.FullName, users.Role, users.Email
                                   FROM users
                                   WHERE users.Id = {[userId]});
        return (case userRowOpt of
                  Some row => Some {FullName = row.Users.FullName,
                                    Role = row.Users.Role,
                                    Email = row.Users.Email}
                | None => None)

(* Must be logged in; otherwise redirect to login. Returns user id. *)
fun requireUser () =
    currentUserOpt <- currentUser ();
    if shouldRedirectRequireUser currentUserOpt then
        (Log.debug "session" "requireUser rejected (no session)";
         redirect (bless "/Main/login"))
    else
        case currentUserOpt of
            Some id => return id
          | None => error <xml><p><b>Unexpected session state.</b></p></xml>

(* Like requireUser, but returns name, role, and email from the DB. *)
fun requireUserInfo () =
    userInfoOpt <- currentUserInfo ();
    if shouldRedirectRequireUserInfo
           (case userInfoOpt of
                Some _ => True
              | None => False) then
        (Log.debug "session" "requireUserInfo rejected (no session or user row)";
         redirect (bless "/Main/login"))
    else
        case userInfoOpt of
            Some info => return info
          | None => error <xml><p><b>Unexpected user info state.</b></p></xml>

(* Login page only; redirect to home if already signed in. *)
fun requireGuest () =
    currentUserOpt <- currentUser ();
    if shouldRedirectRequireGuest currentUserOpt then
        (Log.debug "session" "requireGuest redirecting to home";
         redirect (bless "/Main/home"))
    else
        return ()

fun loginByEmail email =
    matchedUserOpt <- oneOrNoRows (SELECT users.Id
                                   FROM users
                                   WHERE users.Email = {[email]});
    case matchedUserOpt of
        Some matchedUser =>
        (login matchedUser.Users.Id;
         return True)
      | None =>
        (Log.warn "session" ("login rejected (email not found): " ^ email);
         setCookie login_error {Value = "Email '" ^ email ^ "' was not found. Please try again.",
                                Expires = None,
                                Secure = False};
         return False)

(* Read login_error once, then clear it. *)
fun consumeLoginError () =
    errorMessageOpt <- getCookie login_error;
    clearCookie login_error;
    return errorMessageOpt

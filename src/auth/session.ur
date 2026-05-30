(* Tracks who is logged in using cookies, and helpers to sign in, sign out, or block access. *)

open Tables

(* Cookie that stores the logged-in user's id. *)
cookie user_session : {UserId : int}

(* Cookie used to show a login error once, then clear it. *)
cookie login_error : string

(* Send headers so the browser does not show a cached copy of the page. *)
fun setNoCacheHeaders () =
    setHeader (blessResponseHeader "Cache-Control") "no-store, no-cache, must-revalidate, max-age=0";
    setHeader (blessResponseHeader "Pragma") "no-cache";
    setHeader (blessResponseHeader "Expires") "0"

fun login userId =
    Log.info "session" ("login user_id=" ^ show userId);
    setCookie user_session {Value = {UserId = userId},
                            Expires = None,
                            Secure = False}

(* Sign out: clear the session and any login error message. *)
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

(* Require a logged-in user; send them to the login page if not. *)
fun requireUser () =
    currentUserOpt <- currentUser ();
    case currentUserOpt of
        None =>
        (Log.debug "session" "requireUser rejected (no session)";
         redirect (bless "/Main/login"))
      | Some id => return id

(* Same as requireUser, but also loads name, role, and email. *)
fun requireUserInfo () =
    userInfoOpt <- currentUserInfo ();
    case userInfoOpt of
        None =>
        (Log.debug "session" "requireUserInfo rejected (no session or user row)";
         redirect (bless "/Main/login"))
      | Some info => return info

(* For the login page only: send already-logged-in users to home. *)
fun requireGuest () =
    currentUserOpt <- currentUser ();
    case currentUserOpt of
        Some _ =>
        (Log.debug "session" "requireGuest redirecting to home";
         redirect (bless "/Main/home"))
      | None =>
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

(* Read the one-time login error message, then delete it. *)
fun consumeLoginError () =
    errorMessageOpt <- getCookie login_error;
    clearCookie login_error;
    return errorMessageOpt

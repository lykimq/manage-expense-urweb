(* Top-level page handlers wired to URLs in app.urp. *)

fun login () =
    Log.info "main" "GET /Main/login";
    Login.page ()

fun logout () =
    Log.info "main" "GET /Main/logout";
    Session.logout ();
    redirect (bless "/Main/login")

fun home () =
    Log.info "main" "GET /Main/home";
    userInfo <- Session.requireUserInfo ();
    Home.page userInfo

fun create () =
    Log.info "main" "GET /Main/create";
    userId <- Session.requireUser ();
    Policy.requireRole Roles.Employee userId;
    Create_expense.page ()

fun detail id =
    Log.info "main" ("GET /Main/detail id=" ^ show id);
    _ <- Session.requireUser ();
    Expense_detail.page id

fun queue () =
    Log.info "main" "GET /Main/queue";
    _ <- Session.requireUser ();
    Approval_queue.page ()

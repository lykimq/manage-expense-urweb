fun login () = Login.page ()

fun logout () =
    Session.logout ();
    redirect (bless "/Main/login")

fun home () = Home.page ()

fun create () = Create_expense.page ()

fun dashboard () = Dashboard.page ()

fun detail () = Expense_detail.page 1

fun queue () = Approval_queue.page ()

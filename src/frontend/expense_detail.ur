(* Expense detail page entry: compose view + actions. *)

fun page expenseId =
    userId <- Session.requireUser ();
    userInfo <- Session.requireUserInfo ();
    detail <- Detail_service.load expenseId;
    actionBody <-
        Expense_detail_actions.actionsSection userId userInfo.Role detail.Expense;
    Layout.wrap "Expense Detail"
      <xml>
        {Expense_detail_view.pageHeader ()}
        {Expense_detail_view.metadataSection detail expenseId}
        {Expense_detail_view.auditSection detail}
        <article>
          <h2>Actions</h2>
          {actionBody}
        </article>
      </xml>

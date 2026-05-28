val groupName = "expense_service_amount"

val validAmountParses =
    Test_harness.mkResult "parseAmountValue accepts valid decimal input"
      (case Expense_service.parseAmountValue "12.50" of
           Some _ => True
         | None => False)

val invalidAmountRejected =
    Test_harness.mkResult "parseAmountValue rejects non-numeric input"
      (case Expense_service.parseAmountValue "abc" of
           None => True
         | Some _ => False)

val emptyAmountRejected =
    Test_harness.mkResult "parseAmountValue rejects empty input"
      (case Expense_service.parseAmountValue "" of
           None => True
         | Some _ => False)

val results : list Test_harness.test_result =
    validAmountParses ::
    invalidAmountRejected ::
    emptyAmountRejected ::
    []

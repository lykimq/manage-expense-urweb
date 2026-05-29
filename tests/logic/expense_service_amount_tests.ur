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

fun amountCheckMsg amount =
    case Expense_service.amountCheckResult amount of
        (_, msg) => msg

val amountCheckSuccessMessage =
    Test_harness.mkResult "amountCheckResult success message includes parsed value"
      (case Expense_service.parseAmountValue "12.50" of
           Some parsed =>
           amountCheckMsg "12.50" = "Valid amount: " ^ show parsed
         | None => False)

val amountCheckFailureMessage =
    Test_harness.mkResult "amountCheckResult failure message for RPC feedback"
      (amountCheckMsg "abc" = "Amount must be a valid number (same rule as on submit).")

val results : list Test_harness.test_result =
    validAmountParses ::
    invalidAmountRejected ::
    emptyAmountRejected ::
    amountCheckSuccessMessage ::
    amountCheckFailureMessage ::
    []

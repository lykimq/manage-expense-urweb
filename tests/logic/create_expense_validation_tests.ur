val groupName = "create_expense_validation"

val validFieldsAccepted =
    Test_harness.mkResult "required fields pass when title amount category are present"
      (Create_expense.hasRequiredFields
         {Title = "Taxi", Amount = "12.50", Category = "Travel", Description = "Ride"})

val missingTitleRejected =
    Test_harness.mkResult "required fields fail when title is missing"
      (not (Create_expense.hasRequiredFields
              {Title = "", Amount = "12.50", Category = "Travel", Description = ""}))

val missingAmountRejected =
    Test_harness.mkResult "required fields fail when amount is missing"
      (not (Create_expense.hasRequiredFields
              {Title = "Taxi", Amount = "", Category = "Travel", Description = ""}))

val missingCategoryRejected =
    Test_harness.mkResult "required fields fail when category is missing"
      (not (Create_expense.hasRequiredFields
              {Title = "Taxi", Amount = "12.50", Category = "", Description = ""}))

val results : list Test_harness.test_result =
    validFieldsAccepted ::
    missingTitleRejected ::
    missingAmountRejected ::
    missingCategoryRejected ::
    []

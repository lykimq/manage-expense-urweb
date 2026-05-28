fun main () : transaction page =
    expenseServiceResults <- Expense_service_tests.runAll ();
    dashboardServiceResults <- Dashboard_service_tests.runAll ();
    detailServiceResults <- Detail_service_tests.runAll ();
    policyResults <- Policy_tests.runAll ();
    sessionResults <- Session_tests.runAll ();
    let
        val integrationResults =
            List.append expenseServiceResults
                (List.append dashboardServiceResults detailServiceResults)
    in
    let
        val stateResults = State_test.results
        val transitionResults = Transition_test.results
        val amountResults = Expense_service_amount_tests.results
        val createValidationResults = Create_expense_validation_tests.results

        val passedCount =
            Test_harness.countPassed stateResults
            + Test_harness.countPassed transitionResults
            + Test_harness.countPassed amountResults
            + Test_harness.countPassed createValidationResults
            + Test_harness.countPassed policyResults
            + Test_harness.countPassed sessionResults
            + Test_harness.countPassed integrationResults
        val totalCount =
            Test_harness.countTotal stateResults
            + Test_harness.countTotal transitionResults
            + Test_harness.countTotal amountResults
            + Test_harness.countTotal createValidationResults
            + Test_harness.countTotal policyResults
            + Test_harness.countTotal sessionResults
            + Test_harness.countTotal integrationResults

        val allPassed =
            Test_harness.allPassed stateResults
            && Test_harness.allPassed transitionResults
            && Test_harness.allPassed amountResults
            && Test_harness.allPassed createValidationResults
            && Test_harness.allPassed policyResults
            && Test_harness.allPassed sessionResults
            && Test_harness.allPassed integrationResults

        val reportText =
            Test_harness.formatGroup State_test.groupName stateResults
            ^ Test_harness.formatGroup Transition_test.groupName transitionResults
            ^ Test_harness.formatGroup Expense_service_amount_tests.groupName amountResults
            ^ Test_harness.formatGroup Create_expense_validation_tests.groupName createValidationResults
            ^ Test_harness.formatGroup Policy_tests.groupName policyResults
            ^ Test_harness.formatGroup Session_tests.groupName sessionResults
            ^ Test_harness.formatGroup Expense_service_tests.groupName expenseServiceResults
            ^ Test_harness.formatGroup Dashboard_service_tests.groupName dashboardServiceResults
            ^ Test_harness.formatGroup Detail_service_tests.groupName detailServiceResults

        val summaryText =
            "SUMMARY " ^ show passedCount ^ "/" ^ show totalCount ^ " passed"
        val resultText =
            "RESULT " ^ (if allPassed then "ALL_TESTS_PASSED" else "TESTS_FAILED")
    in
        return <xml>
          <head><title>Test Suite</title></head>
          <body>
            <h1>Test Suite</h1>
            <p>
              Combined logic and service integration report.
            </p>
            <pre>
{[reportText]}
{[summaryText]}
{[resultText]}
            </pre>
          </body>
        </xml>
    end
    end

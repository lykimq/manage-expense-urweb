fun main () : transaction page =
    expenseServiceResults <- Expense_service_tests.runAll ();
    dashboardServiceResults <- Dashboard_service_tests.runAll ();
    detailServiceResults <- Detail_service_tests.runAll ();
    let
        val integrationResults =
            List.append expenseServiceResults
                (List.append dashboardServiceResults detailServiceResults)
    in
    let
        val stateResults = State_test.results
        val transitionResults = Transition_test.results
        val policyResults = Policy_tests.results
        val sessionResults = Session_tests.results

        val passedCount =
            Test_harness.countPassed stateResults
            + Test_harness.countPassed transitionResults
            + Test_harness.countPassed policyResults
            + Test_harness.countPassed sessionResults
            + Test_harness.countPassed integrationResults
        val totalCount =
            Test_harness.countTotal stateResults
            + Test_harness.countTotal transitionResults
            + Test_harness.countTotal policyResults
            + Test_harness.countTotal sessionResults
            + Test_harness.countTotal integrationResults

        val allPassed =
            Test_harness.allPassed stateResults
            && Test_harness.allPassed transitionResults
            && Test_harness.allPassed policyResults
            && Test_harness.allPassed sessionResults
            && Test_harness.allPassed integrationResults

        val reportText =
            Test_harness.formatGroup State_test.groupName stateResults
            ^ Test_harness.formatGroup Transition_test.groupName transitionResults
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

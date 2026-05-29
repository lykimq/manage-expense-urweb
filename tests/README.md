# Test Suite (Ur/Web Demo)

This folder contains the automated tests for the expense workflow demo.

The goal is simple: verify the core business rules and service behavior that
the demo is meant to show, without adding complex UI testing.

## Approach

The suite uses a small in-project test harness (`tests/test_harness.*`) and a
single test entry point (`tests/test_main.ur`) that is run through `make test`.

Tests are split by concern:

- `tests/logic/`: pure rule checks (state, transitions, policy, session)
- `tests/integration/`: service-level checks using real DB operations on a
  dedicated test database (`expense_test_db`)
- `tests/http.urp` + `tests/http_checks.sh`: HTTP-level checks for redirects,
  login/logout flow, and queue access denial behavior

This structure matches the implementation style:

- workflow rules in `src/workflow/`
- authorization/session behavior in `src/auth/`
- transactional business behavior in `src/service/`

## Why this fits Ur/Web well

Ur/Web already gives compile-time safety for SQL shapes, forms, links, and
handler wiring. The tests focus on what still must be validated at runtime:

- business invariants
- role authorization decisions
- allowed and denied state transitions
- audit side effects across service calls
- server-side rules used by Ur/Web RPC (for example create-expense amount check
  messages), without driving the browser

This gives practical confidence while keeping the suite small and easy to run.

## Why not mock the database

For this project, integration tests intentionally use PostgreSQL instead of a
mock database:

- they need to verify transaction side effects across multiple writes
- they need to verify real schema constraints and query behavior
- they need to verify audit log persistence exactly as production code uses it

A mock can still be useful for isolated unit tests, but it cannot replace these
end-to-end data checks.

## What the tests cover

Logic tests:

- `state_test`: state string mapping and parsing behavior
- `transition_test`: transition truth table and invariants
- `expense_service_amount_tests`: amount parsing (`parseAmountValue`) and the
  `(ok, message)` pairs from `amountCheckResult` used by the create-expense
  **Check amount** RPC (success and failure banner text only; not a second copy
  of accept/reject cases)
- `create_expense_validation_tests`: required-field checks on the create form
  (`hasRequiredFields` in the frontend; separate from numeric amount parsing)
- `policy_tests`: role matching and owner/non-owner checks via Policy module
- `session_tests`: Session module checks (login, logout, cookie helpers)

Integration tests:

- `expense_service_tests`: create -> approve/pay/reject flows and audit rows
- `dashboard_service_tests`: role-based workspace and queue data
- `detail_service_tests`: detail payload, owner name, audit timeline shape

HTTP checks:

- unauthenticated `/Main/home` redirects to `/Main/login`
- authenticated user visiting `/Main/login` redirects to `/Main/home`
- login and logout flow works with real cookies
- Employee access to `/Main/queue` is denied with server-rendered error message

## What this suite does not focus on

- browser UI interaction testing (including clicking **Check amount** or exercising
  the `rpc (...)` wire-up in `Create_expense`)
- visual assertions
- load/performance testing
- distributed or multi-service testing

For this demo project, that is intentional. The suite focuses on correctness of
the workflow and service logic. RPC is covered at the layer that matters for
rules: `Expense_service.amountCheckResult` and related parsing, while session
and role gates for that path are covered by `session_tests` and `policy_tests`.

## Run tests

From repo root:

```bash
make test
```

`make test` initializes and uses only the dedicated test database
(`expense_test_db`). It does not need app DB data, and it runs both:

- the in-process test suite at `/Test_main/main`
- HTTP integration checks against `tests/http.urp`

The output is grouped by test module and ends with a pass/fail summary.

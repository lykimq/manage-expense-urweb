# Test Suite (Ur/Web Demo)

This folder contains the automated tests for the expense workflow demo.

The goal is simple: verify the core business rules and service behavior that
the demo is meant to show, without adding complex UI testing.

## Approach

The suite uses a small in-project test harness (`tests/test_harness.*`) and a
single test entry point (`tests/test_main.ur`) that is run through `make test`.

Tests are split by concern:

- `tests/logic/`: pure rule checks (state, transitions, policy, session)
- `tests/integration/`: service-level checks using real DB operations

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

This gives practical confidence while keeping the suite small and easy to run.

## What the tests cover

Logic tests:

- `state_test`: state string mapping and parsing behavior
- `transition_test`: transition truth table and invariants
- `policy_tests`: role matching and owner/non-owner checks
- `session_tests`: session and redirect decision helpers

Integration tests:

- `expense_service_tests`: create -> approve -> pay flow and audit rows
- `dashboard_service_tests`: role-based workspace and queue data
- `detail_service_tests`: detail payload, owner name, audit timeline shape

## What this suite does not focus on

- browser UI interaction testing
- visual assertions
- load/performance testing
- distributed or multi-service testing

For this demo project, that is intentional. The suite focuses on correctness of
the workflow and service logic.

## Run tests

From repo root:

```bash
make test
```

The output is grouped by test module and ends with a pass/fail summary.

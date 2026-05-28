# Expense Workflow Demo in Ur/Web

This project is a small expense approval workflow built with Ur/Web and PostgreSQL.

It is intentionally a demo, not a production expense system. The goal is to show
where Ur/Web is strong: explicit workflow state, typed forms, typed SQL,
server-side authorization, and simple transactional code that is still easy to
reason about.

## Why this is a good Ur/Web demo

An expense workflow is small enough to understand quickly, but it still has real
rules:

- different roles do different work
- state transitions matter
- invalid actions must be denied on the server
- the database should reflect the same rules as the application
- every change should leave an audit trail

That makes it a good fit for Ur/Web. The app is not trying to impress with UI
polish. It is trying to make the core business rules obvious.

## What the demo currently does

- login by seeded email for three roles: Employee, Manager, Finance
- create a new expense as `Submitted`
- approve or reject a `Submitted` expense as Manager
- mark an `Approved` expense as paid as Finance
- show a role-based home view and queue view
- show one expense detail page with metadata and audit history
- protect the main routes behind a signed session cookie

## Demo walkthrough (quick)

Use this quick flow to demo the app:

1. login as Employee (`quyen_ly@example.com`)
2. create a new expense (it starts as `Submitted`)
3. logout, then login as Manager (`boss@example.com`)
4. open the queue or detail page, then approve or reject
5. logout, then login as Finance (`finance@example.com`)
6. mark an `Approved` expense as paid
7. open expense detail and check the audit timeline

## Core invariants

These are the rules the demo is built around:

- only Employees create expenses
- only Managers approve or reject
- only Finance marks paid
- only `Submitted` can become `Approved` or `Rejected`
- only `Approved` can become `Paid`
- Managers cannot act on their own expense
- every successful state change writes an audit row
- failed actions should not leave partial writes behind

## What it focuses on

This demo focuses on:

- correctness over feature count
- a small but real workflow
- type-safe form handling
- typed database access
- simple module boundaries for auth, workflow, DB, service, and frontend
- auditability

## What it does not focus on yet

This demo does not try to solve everything:

- email-only demo login (no password flow)
- no receipt upload
- no email notifications
- no search, reporting, export, or admin tooling
- no fancy frontend behavior
- no ownership rule yet on "employee can only open their own expense detail URL"
- small JS helper (`src/static/bfcache.js`) is still needed for browser BFCache behavior

Those are valid next steps, but they would distract from the main point of the
demo in its current state.

## Ur/Web strengths and guarantees in this demo

This project uses Ur/Web in an ML-style way:

- algebraic datatypes model workflow state in `src/workflow/state.ur`
- pattern matching in `src/workflow/transition.ur` keeps transitions explicit
- small pure helpers are separated from side-effecting service functions
- typed records from forms and DB rows reduce stringly-typed glue code

It also gets practical compile-time guarantees:

- form handlers match the fields they consume
- SQL query shapes are checked against declared tables
- links/actions stay aligned with handler signatures
- cookie + side-effect handling uses Ur/Web signing rules
- action handlers run inside transactions, which fits the workflow + audit model

What Ur/Web does not automatically prove for this app:

- role authorization still needs explicit checks in `src/auth/policy.ur`
- transition validity still needs explicit checks in `src/service/expense_service.ur`
- relational integrity still needs constraints in `schema/extra.sql`

So the right claim for this demo is: strong static guarantees plus explicit
runtime invariants, not "everything is automatically formally verified."

## Friction points and workarounds

This project also shows where Ur/Web is less smooth in practice.

### 1. Rich SQL constraints still need extra SQL

`schema/tables.ur` is the source of the table layout, but it is not enough for
the full relational design. This project adds primary keys, foreign keys,
uniqueness, check constraints, and indexes in `schema/extra.sql`.

That is one of the clearest lessons from the demo: Ur/Web gives strong typed
SQL, but you may still want handwritten SQL for the final shape of the database.

For this repo, concrete examples in `schema/extra.sql` are:

- `chk_expenses_state` for allowed workflow states
- foreign keys from expenses and audit rows to users/expenses
- indexes for queue filtering and owner lookups

### 2. Workflow ADTs do not map directly into SQL columns

In Ur/Web code, expense state is best modeled as an algebraic datatype. In the
database, this project stores state as strings and converts at the application
boundary.

That is workable, but it is manual. The upside is that the application code can
still reason in terms of explicit states instead of raw strings.

### 3. Browser behavior still sometimes needs JavaScript

The app includes `src/static/bfcache.js` to force a reload when a page is
restored from the browser back/forward cache. Without that, the browser can show
a stale page without hitting the server again, which is a bad fit for
session-sensitive flows like login, logout, and protected pages.

This is a good reminder that Ur/Web covers a lot, but browser platform quirks
can still leak through and require a small JS escape hatch.

### 4. Configuration is explicit in this project

In this repo, a few important behaviors are configured directly in `app.urp`:

- module order is part of compilation: modules listed earlier are available to
  modules listed later, so the workflow/auth/db/service/frontend order is
  intentional
- static files are declared with `file` and then whitelisted with `allow url`
  (CSS files and `/bfcache.js` are configured this way)
- route URLs are explicitly whitelisted with `allow url` (for example
  `/Main/login`, `/Main/home`, `/Main/detail/*`)
- response headers used by session cache-control are explicitly allowed
  (`Cache-Control`, `Pragma`, `Expires`)
- `sigfile app.sig` is required because handlers in this app read cookies and
  perform side effects

For this demo, that explicit setup is useful: you can see the security and
routing surface in one place, but there is less convention-driven behavior than
in larger web frameworks.

## One request flow example: approve expense

The "approve" path is intentionally simple:

1. Manager opens expense detail and submits an action form
2. frontend calls service function in `src/service/expense_service.ur`
3. service checks role policy and "not owner" rule
4. service checks state transition validity
5. service updates expense state
6. service inserts one audit row
7. page redirects back to detail

This is the core pattern used by reject and pay as well.

## Quick start

```bash
make db
make web
```

Open `http://localhost:8081/Main/login`.

Seeded demo users:

- Employee: `quyen_ly@example.com`
- Manager: `boss@example.com`
- Finance: `finance@example.com`

Useful commands:

```bash
make db           # schema + extra.sql constraints + seed data
make web          # run local dev server on port 8081
make test-db      # create and seed dedicated test database
make test         # full automated test suite (uses expense_test_db)
make remove-db    # clear app tables and reset sequences
make clean-session
```

## Tests

The project includes a focused automated suite under `tests/`.

- logic tests validate workflow, policy, and session rules
- integration tests validate service behavior and audit side effects
- `make test` runs the suite against a dedicated test database (`expense_test_db`)
  and prints grouped results plus a final summary

Why this project uses a real dedicated test database instead of a mock:

- workflow correctness depends on real SQL constraints, transaction behavior, and
  persisted audit rows
- service tests need to validate DB side effects (`create`, transition updates,
  audit inserts) end to end
- a mock DB can hide query/constraint/transaction issues that only appear in
  PostgreSQL
- a dedicated test DB keeps this confidence without polluting app/dev data

This is intentionally not a UI testing setup. For this demo, tests focus on
business correctness, authorization rules, state transitions, and transactional
effects in the database.

See `tests/README.md` for details.

## If you are learning Ur/Web

This repo is most useful if you read it as a small case study:

1. start with the workflow states and role rules
2. look at `src/auth/` for session and role checks
3. look at `src/service/expense_service.ur` for the transaction boundaries
4. compare `schema/tables.ur` with `schema/extra.sql`
5. inspect `src/frontend/` last, after the rules are clear

That order matches the point of the project: business rules first, UI second.

## Repo map (short)

- `src/auth`: session and authorization checks
- `src/workflow`: state model and transition rules
- `src/service`: transactional business actions
- `src/db`: typed database access functions
- `src/frontend`: pages and form handlers
- `tests`: logic and integration test suite (runs on dedicated test DB)
- `schema`: table declarations, extra constraints, seed data
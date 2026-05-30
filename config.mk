# Project settings (edit values here; Makefile includes this file).

PROJECT  := app
PORT     := 8081
DB       := expense_db
TEST_DB  := expense_test_db

# Tool commands (override on the command line: make URWEB=/path/to/urweb web)
URWEB    ?= urweb
PSQL     ?= psql
CREATEDB ?= createdb

# Schema and seed paths (relative to project root)
SQL       := schema/schema.sql
EXTRA_SQL := schema/extra.sql
SEED_SQL  := schema/seed.sql

# Table used by make check-db / setup_db to detect an initialized database
SQL_TABLE := uw_tables_expenses
TEST_SQL_TABLE := $(SQL_TABLE)

# CSRF signing key filename (must match sigfile in app.urp)
SIG := app.sig

# Ur/Web sources watched for rebuild.
# APP_SRCS: app + schema only (make web does not rebuild on test edits).
# TEST_SRCS: test modules, including tests/*.ur (test_main, test_harness).
SRC_SUBDIRS := util auth db service workflow frontend
TEST_SUBDIRS := logic integration

APP_SRCS := $(wildcard src/*.ur src/*.urs schema/*.ur schema/*.urs) \
            $(foreach d,$(SRC_SUBDIRS),$(wildcard src/$(d)/*.ur src/$(d)/*.urs))

TEST_SRCS := $(wildcard tests/*.ur tests/*.urs) \
             $(foreach d,$(TEST_SUBDIRS),$(wildcard tests/$(d)/*.ur tests/$(d)/*.urs))

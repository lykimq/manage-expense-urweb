# Project settings (edit values here; Makefile includes this file).

PROJECT  := app
PORT     := 8081
DB       := expense_db

# Tool commands (override on the command line: make URWEB=/path/to/urweb web)
URWEB    ?= urweb
PSQL     ?= psql
CREATEDB ?= createdb

# Schema and seed paths (relative to project root)
SQL       := schema/schema.sql
EXTRA_SQL := schema/extra.sql
SEED_SQL  := schema/seed.sql

# Table used by make check-db to detect an initialized database
SQL_TABLE := uw_tables_expenses

# CSRF signing key filename (must match sigfile in app.urp)
SIG := app.sig

# Ur/Web sources watched for rebuild (add a directory when you add a module tree)
APP_SRCS := $(wildcard src/*.ur) \
            $(wildcard src/*.urs) \
            $(wildcard tests/logic/*.ur) \
            $(wildcard tests/logic/*.urs) \
            $(wildcard tests/integration/*.ur) \
            $(wildcard tests/integration/*.urs) \
            $(wildcard src/util/*.ur) \
            $(wildcard src/util/*.urs) \
            $(wildcard src/auth/*.ur) \
            $(wildcard src/auth/*.urs) \
            $(wildcard src/db/*.ur) \
            $(wildcard src/db/*.urs) \
            $(wildcard src/service/*.ur) \
            $(wildcard src/service/*.urs) \
            $(wildcard src/workflow/*.ur) \
            $(wildcard src/workflow/*.urs) \
            $(wildcard src/frontend/*.ur) \
            $(wildcard src/frontend/*.urs) \
            $(wildcard schema/*.ur) \
            $(wildcard schema/*.urs)

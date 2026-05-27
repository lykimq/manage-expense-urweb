PROJECT := app
PORT    := 8081
DB      := expense_db
URWEB   ?= urweb
PSQL    ?= psql
CREATEDB ?= createdb

URP        := $(PROJECT).urp
EXE        := $(PROJECT).exe
SQL        := schema/schema.sql
EXTRA_SQL  := schema/extra.sql
SEED_SQL   := schema/seed.sql
URL        := http://localhost:$(PORT)/Main/home
SQL_TABLE  := uw_tables_expenses

APP_SRCS   := $(wildcard src/*.ur) \
              $(wildcard src/*.urs) \
              $(wildcard src/frontend/*.ur) \
              $(wildcard src/frontend/*.urs) \
              $(wildcard schema/*.ur) \
              $(wildcard schema/*.urs)

.PHONY: all help web test db seed check-db clean

all: help

help:
	@echo "Targets:"
	@echo "  make db       Setup database (schema + constraints + seed)"
	@echo "  make web      Build and run dev server (auto rebuild app only)"
	@echo "  make seed     Re-apply sample data (requires db)"
	@echo "  make test     Build, run server briefly, and smoke test"
	@echo "  make clean    Remove app.exe and generated SQL"

$(EXE): $(URP) $(APP_SRCS)
	$(URWEB) $(PROJECT)

$(SQL): $(URP) $(APP_SRCS)
	$(URWEB) $(PROJECT)

# One-time database setup: generate schema, apply tables, constraints, seed.
db: $(SQL)
	-$(CREATEDB) $(DB) 2>/dev/null || true
	@if $(PSQL) -tAc "SELECT 1 FROM information_schema.tables WHERE table_name = '$(SQL_TABLE)'" $(DB) | grep -q 1; then \
		echo "db: tables already exist ($(DB))"; \
	else \
		echo "db: applying schema ($(DB))"; \
		$(PSQL) -v ON_ERROR_STOP=1 -f $(SQL) $(DB); \
	fi
	@if [ -f "$(EXTRA_SQL)" ]; then \
		$(PSQL) -v ON_ERROR_STOP=1 -f $(EXTRA_SQL) $(DB); \
	fi
	@if [ -f "$(SEED_SQL)" ]; then \
		$(PSQL) -v ON_ERROR_STOP=1 -f $(SEED_SQL) $(DB); \
	fi
	@echo "db: ready ($(DB))"

# Lightweight check used by web/test; does not modify the database.
check-db:
	@if ! $(PSQL) -tAc "SELECT 1 FROM information_schema.tables WHERE table_name = '$(SQL_TABLE)'" $(DB) 2>/dev/null | grep -q 1; then \
		echo "db: not ready. Run 'make db' first."; \
		exit 1; \
	fi

seed: check-db
	@if [ -f "$(SEED_SQL)" ]; then \
		$(PSQL) -v ON_ERROR_STOP=1 -f $(SEED_SQL) $(DB); \
		echo "seed: sample data applied ($(DB))"; \
	else \
		echo "seed: missing $(SEED_SQL)"; \
		exit 1; \
	fi

web: check-db $(EXE)
	@url="$(URL)"; \
	if ! command -v inotifywait >/dev/null 2>&1; then \
		echo "inotifywait not found. Install inotify-tools to use auto rebuild in make web."; \
		exit 1; \
	fi; \
	printf '\n  Open in browser: '; \
	printf '\033]8;;%s\033\\%s\033]8;;\033\\\n' "$$url" "$$url"; \
	printf '  (or %s)\n\n' "$$url"; \
	while true; do \
		if $(MAKE) --no-print-directory $(EXE); then \
			./$(EXE) -p $(PORT) & pid=$$!; \
		else \
			pid=""; \
		fi; \
		inotifywait -qq -r -e close_write,create,delete,move --exclude '(^|/)\.git/' .; \
		if [ -n "$$pid" ]; then \
			kill $$pid 2>/dev/null || true; \
			wait $$pid 2>/dev/null || true; \
		fi; \
		echo "Change detected. Rebuilding app..."; \
	done

test: check-db $(EXE)
	@./$(EXE) -p $(PORT) & \
	pid=$$!; \
	sleep 1; \
	if curl -sf $(URL) | grep -q 'Expense'; then \
		echo "test: ok ($(URL))"; \
		rc=0; \
	else \
		echo "test: failed ($(URL))"; \
		rc=1; \
	fi; \
	kill $$pid 2>/dev/null || true; \
	wait $$pid 2>/dev/null || true; \
	exit $$rc

clean:
	rm -f $(EXE) $(SQL)

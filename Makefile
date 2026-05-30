include config.mk

URP := $(PROJECT).urp
EXE := $(PROJECT).exe
URL := http://localhost:$(PORT)/Main/login
TEST_EXE := tests/test.exe tests/http.exe
TEST_RUN := bash tests/run.sh

.PHONY: all help web test schema db seed remove-db check-db clean-session clean test-db

all: help

help:
	@echo "Targets:"
	@echo "  make schema   Regenerate schema/schema.sql from tables.ur (commit after schema changes)"
	@echo "  make db       Setup database (schema + constraints + seed)"
	@echo "  make test-db      Setup dedicated test database"
	@echo "  make web      Build and run dev server (auto rebuild app only)"
	@echo "  make seed         Re-apply sample data (requires db)"
	@echo "  make remove-db    Delete all app rows and reset sequences"
	@echo "  make test         Run logic/integration + HTTP checks"
	@echo "  make clean-session  Drop the session signing key ($(SIG))"
	@echo "  make clean        Remove build outputs and signing keys"

tests/test.exe: tests/test.urp $(APP_SRCS)
	$(URWEB) $(URWEB_FLAGS) tests/test

tests/http.exe: tests/http.urp $(APP_SRCS)
	$(URWEB) $(URWEB_FLAGS) tests/http

$(EXE): $(URP) $(APP_SRCS)
	$(URWEB) $(URWEB_FLAGS) $(PROJECT)

# SQL only: stop before C codegen/link (make web still builds $(EXE) separately).
$(SQL): $(URP) $(APP_SRCS)
	$(URWEB) $(URWEB_FLAGS) -stop sqlify -sql $(SQL) $(PROJECT)

schema: $(SQL)
	@echo "schema: wrote $(SQL)"

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

test-db: $(SQL)
	-$(CREATEDB) $(TEST_DB) 2>/dev/null || true
	@if $(PSQL) -tAc "SELECT 1 FROM information_schema.tables WHERE table_name = '$(TEST_SQL_TABLE)'" $(TEST_DB) | grep -q 1; then \
		echo "test-db: tables already exist ($(TEST_DB))"; \
	else \
		echo "test-db: applying schema ($(TEST_DB))"; \
		$(PSQL) -v ON_ERROR_STOP=1 -f $(SQL) $(TEST_DB); \
	fi
	@if [ -f "$(EXTRA_SQL)" ]; then \
		$(PSQL) -v ON_ERROR_STOP=1 -f $(EXTRA_SQL) $(TEST_DB); \
	fi
	@if [ -f "$(SEED_SQL)" ]; then \
		$(PSQL) -v ON_ERROR_STOP=1 -f $(SEED_SQL) $(TEST_DB); \
	fi
	@echo "test-db: ready ($(TEST_DB))"

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

remove-db: check-db
	@$(PSQL) -v ON_ERROR_STOP=1 $(DB) -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$(DB)' AND pid <> pg_backend_pid();"
	@$(PSQL) -v ON_ERROR_STOP=1 $(DB) -c "TRUNCATE TABLE uw_tables_audit_log, uw_tables_expenses, uw_tables_users RESTART IDENTITY CASCADE;"
	@echo "remove-db: cleared app tables and reset sequences ($(DB))"

web: check-db $(EXE)
	@url="$(URL)"; \
	if ! command -v inotifywait >/dev/null 2>&1; then \
		echo "inotifywait not found. Install inotify-tools to use auto rebuild in make web."; \
		exit 1; \
	fi; \
	rm -f $(SIG); \
	echo "web: rotated $(SIG); previous browser sessions are now invalid."; \
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

# Use make -j2 test in CI so tests/test.exe and tests/http.exe build in parallel.
test: test-db $(TEST_EXE)
	$(TEST_RUN)

clean-session:
	rm -f $(SIG)
	@echo "clean-session: removed $(SIG); existing browser sessions are now invalid."

clean:
	rm -f $(EXE) tests/test.exe tests/http.exe $(SQL) $(SIG) test.sig

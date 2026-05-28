include config.mk

URP := $(PROJECT).urp
EXE := $(PROJECT).exe
URL := http://localhost:$(PORT)/Main/login
TEST_PORT ?= 18081
TEST_URL := http://localhost:$(TEST_PORT)/Main/login
TEST_SUITE_PROJECT := tests/test
TEST_SUITE_URP := $(TEST_SUITE_PROJECT).urp
TEST_SUITE_EXE := $(TEST_SUITE_PROJECT).exe
TEST_SUITE_PORT ?= 18082
TEST_SUITE_URL := http://localhost:$(TEST_SUITE_PORT)/Test_main/main
HTTP_TEST_PROJECT := tests/http
HTTP_TEST_URP := $(HTTP_TEST_PROJECT).urp
HTTP_TEST_EXE := $(HTTP_TEST_PROJECT).exe
HTTP_TEST_PORT ?= 18083
HTTP_TEST_BASE_URL := http://localhost:$(HTTP_TEST_PORT)

.PHONY: all help web test db seed remove-db check-db clean-session clean

all: help

help:
	@echo "Targets:"
	@echo "  make db       Setup database (schema + constraints + seed)"
	@echo "  make test-db      Setup dedicated test database"
	@echo "  make web      Build and run dev server (auto rebuild app only)"
	@echo "  make seed         Re-apply sample data (requires db)"
	@echo "  make remove-db    Delete all app rows and reset sequences"
	@echo "  make test         Run full suite + HTTP integration checks"
	@echo "  make clean-session  Drop the session signing key ($(SIG))"
	@echo "  make clean        Remove app.exe, generated SQL, and $(SIG)"

$(TEST_SUITE_EXE): $(TEST_SUITE_URP) $(APP_SRCS)
	$(URWEB) $(TEST_SUITE_PROJECT)

$(HTTP_TEST_EXE): $(HTTP_TEST_URP) $(APP_SRCS)
	$(URWEB) $(HTTP_TEST_PROJECT)

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

# One-time test database setup: dedicated DB for integration tests.
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

test: test-db $(TEST_SUITE_EXE) $(HTTP_TEST_EXE)
	@if ss -ltn "( sport = :$(TEST_SUITE_PORT) )" | tail -n +2 | grep -q .; then \
		echo "test-suite: port $(TEST_SUITE_PORT) is already in use. Override with TEST_SUITE_PORT=<port>."; \
		exit 1; \
	fi
	@./$(TEST_SUITE_EXE) -p $(TEST_SUITE_PORT) & \
	pid=$$!; \
	sleep 1; \
	if ! kill -0 $$pid 2>/dev/null; then \
		echo "test-suite: app failed to start on port $(TEST_SUITE_PORT)."; \
		wait $$pid 2>/dev/null || true; \
		exit 1; \
	fi; \
	body=$$(curl -sf $(TEST_SUITE_URL)); \
	decoded=$$(printf '%s\n' "$$body" | sed 's/&#10;/\n/g'); \
	printf '%s\n' "$$decoded" | grep -oE '^(TEST|SUMMARY|RESULT).*' || true; \
	if printf '%s\n' "$$body" | grep -q 'ALL_TESTS_PASSED'; then \
		echo "test-suite: ok ($(TEST_SUITE_URL))"; \
		rc=0; \
	else \
		echo "test-suite: failed ($(TEST_SUITE_URL))"; \
		rc=1; \
	fi; \
	kill $$pid 2>/dev/null || true; \
	wait $$pid 2>/dev/null || true; \
	if [ $$rc -ne 0 ]; then \
		exit $$rc; \
	fi; \
	if ss -ltn "( sport = :$(HTTP_TEST_PORT) )" | tail -n +2 | grep -q .; then \
		echo "http-checks: port $(HTTP_TEST_PORT) is already in use. Override with HTTP_TEST_PORT=<port>."; \
		exit 1; \
	fi; \
	./$(HTTP_TEST_EXE) -p $(HTTP_TEST_PORT) & \
	pid=$$!; \
	sleep 1; \
	if ! kill -0 $$pid 2>/dev/null; then \
		echo "http-checks: app failed to start on port $(HTTP_TEST_PORT)."; \
		wait $$pid 2>/dev/null || true; \
		exit 1; \
	fi; \
	bash tests/http_checks.sh "$(HTTP_TEST_BASE_URL)"; \
	rc=$$?; \
	kill $$pid 2>/dev/null || true; \
	wait $$pid 2>/dev/null || true; \
	exit $$rc

clean-session:
	rm -f $(SIG)
	@echo "clean-session: removed $(SIG); existing browser sessions are now invalid."

clean:
	rm -f $(EXE) $(TEST_SUITE_EXE) $(HTTP_TEST_EXE) $(SQL) $(SIG) test.sig

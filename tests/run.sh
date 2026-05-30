#!/usr/bin/env bash
# Run logic/integration suite then HTTP checks. Called by: make test
set -euo pipefail

suite_exe="${SUITE_EXE:-tests/test.exe}"
suite_port="${SUITE_PORT:-18082}"
suite_url="${SUITE_URL:-http://localhost:${suite_port}/Test_main/main}"
http_exe="${HTTP_EXE:-tests/http.exe}"
http_port="${HTTP_PORT:-18083}"
http_base="${HTTP_BASE:-http://localhost:${http_port}}"

port_in_use() {
  ss -ltn "( sport = :$1 )" 2>/dev/null | tail -n +2 | grep -q .
}

with_server() {
  local exe="$1" port="$2" label="$3"
  shift 3

  if port_in_use "$port"; then
    echo "${label}: port ${port} is already in use."
    exit 1
  fi

  "$exe" -p "$port" &
  local pid=$!
  sleep 1
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "${label}: failed to start on port ${port}."
    wait "$pid" 2>/dev/null || true
    exit 1
  fi

  "$@"
  local rc=$?
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  return "$rc"
}

run_suite() {
  local body
  body="$(curl -sf "$suite_url")"
  printf '%s\n' "$body" | sed 's/&#10;/\n/g' | grep -oE '^(TEST|SUMMARY|RESULT).*' || true
  if printf '%s\n' "$body" | grep -q 'ALL_TESTS_PASSED'; then
    echo "test-suite: ok (${suite_url})"
  else
    echo "test-suite: failed (${suite_url})"
    return 1
  fi
}

with_server "$suite_exe" "$suite_port" "test-suite" run_suite
with_server "$http_exe" "$http_port" "http-checks" \
  bash tests/http_checks.sh "$http_base"
echo "test: ok"

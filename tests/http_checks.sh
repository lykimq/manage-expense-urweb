#!/usr/bin/env bash
set -euo pipefail

base_url="${1:?base URL required}"
cookie_jar="$(mktemp)"
trap 'rm -f "$cookie_jar"' EXIT

expect_redirect() {
  local url="$1"
  local expected_location="$2"
  local extra_args="${3:-}"
  local headers
  # shellcheck disable=SC2086
  headers="$(curl -sS -D - -o /dev/null $extra_args "$url")"
  if ! printf '%s\n' "$headers" | rg -q "^HTTP/.* 30[12378]"; then
    echo "Expected redirect at $url"
    echo "$headers"
    return 1
  fi
  if ! printf '%s\n' "$headers" | rg -q "^Location: ${expected_location}\r?$"; then
    echo "Expected Location: $expected_location at $url"
    echo "$headers"
    return 1
  fi
}

expect_contains() {
  local url="$1"
  local expected_text="$2"
  local extra_args="${3:-}"
  local body
  # shellcheck disable=SC2086
  body="$(curl -sS $extra_args "$url")"
  if ! printf '%s\n' "$body" | rg -q "$expected_text"; then
    echo "Expected body to contain: $expected_text at $url"
    return 1
  fi
}

# 1) Unauthenticated protected route redirects to login.
expect_redirect "$base_url/Main/home" "/Main/login"

# 2) Parse login form action from page, then login as seeded Employee.
login_page="$(curl -sS -c "$cookie_jar" "$base_url/Main/login")"
login_action="$(printf '%s\n' "$login_page" | rg -o 'action="[^"]+"' | sed -E 's/action="([^"]+)"/\1/' | sed -n '1p')"
if [ -z "$login_action" ]; then
  echo "Could not find login form action in /Main/login"
  exit 1
fi
expect_redirect "$base_url$login_action" "/Main/home" "-b $cookie_jar -c $cookie_jar -X POST --data-urlencode Email=quyen_ly@example.com"

# 3) Authenticated user hitting login gets redirected to home.
expect_redirect "$base_url/Main/login" "/Main/home" "-b $cookie_jar -c $cookie_jar"

# 4) Employee cannot access approval queue.
expect_contains "$base_url/Main/queue" "You are not allowed to view the approval queue" "-b $cookie_jar -c $cookie_jar"

# 5) Logout clears session and protected route redirects again.
expect_redirect "$base_url/Main/logout" "/Main/login" "-b $cookie_jar -c $cookie_jar"
expect_redirect "$base_url/Main/home" "/Main/login" "-b $cookie_jar -c $cookie_jar"

echo "http-checks: ok ($base_url)"

# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


_test.create_file() {
  local file_path
  file_path="$1"
  IFS= read -rd '' script || :
  echo "$script" > "$file_path" 
}

test_handle_invocation_response_fails_if_status_code_is_not_200() {
  source "$SCRIPT_DIR/../lambda.bash"
  set -euo pipefail

  local tmpdir
  tmpdir="$(mktemp -d)"
  #shellcheck disable=SC2064
  trap "rm -rf '$tmpdir'" EXIT

  local stdout_file
  local stderr_file
  stdout_file="$tmpdir/stdout_file"
  stderr_file="$tmpdir/stderr_file"

  __lambda.handle_invocation_response >"$stdout_file" 2>"$stderr_file" <<EOF
HTTP/1.1 405 Not Allowed
Date: Tue, 20 Jan 2026 19:38:42 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
Server: cloudflare
CF-RAY: 9c1108a22bce4a29-YYZ

event_data
EOF
  return_code="$?"
  assert_equals "1" "$return_code"
  assert_no_diff <( echo -n "" ) "$stdout_file"
  assert_no_diff <( echo -n "ERROR: status code of invocation response was not 200. Got code '405'") "$stderr_file"
}

test_handle_event_fails_if_status_code_is_not_200() {
  source "$SCRIPT_DIR/../lambda.bash"
  set -euo pipefail

  local tmpdir
  tmpdir="$(mktemp -d)"
  #shellcheck disable=SC2064
  trap "rm -rf '$tmpdir'" EXIT

  local stdout_file
  local stderr_file
  stdout_file="$tmpdir/stdout_file"
  stderr_file="$tmpdir/stderr_file"

  __lambda.handle_invocation_response >"$stdout_file" 2>"$stderr_file" <<EOF
HTTP/1.1 405 Not Allowed
Date: Tue, 20 Jan 2026 19:38:42 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
Server: cloudflare
CF-RAY: 9c1108a22bce4a29-YYZ

event_data
EOF
  return_code="$?"
  assert_equals "1" "$return_code"
  assert_no_diff <( echo -n "" ) "$stdout_file"
  assert_no_diff <( echo -n "ERROR: status code of invocation response was not 200. Got code '405'") "$stderr_file"
}

test_handle_invocation_response_runs_handler() {
  source "$SCRIPT_DIR/../lambda.bash"
  set -euo pipefail

  local tmpdir
  tmpdir="$(mktemp -d)"
  #shellcheck disable=SC2064
  trap "rm -rf '$tmpdir'" EXIT

  local stdout_file
  local stderr_file
  stdout_file="$tmpdir/stdout_file"
  stderr_file="$tmpdir/stderr_file"


  #shellcheck disable=SC2317
  handler_func() {
    echo -n "ran!" 
  }

  __lambda.set_event_handler_function "handler_func"
  __lambda.handle_invocation_response >"$stdout_file" 2>"$stderr_file" <<EOF
HTTP/1.1 200 OK 
Date: Tue, 20 Jan 2026 19:38:42 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
Server: cloudflare
CF-RAY: 9c1108a22bce4a29-YYZ

event_data
EOF
  return_code="$?"
  assert_equals "0" "$return_code"
  assert_no_diff <( echo -n "ran!" ) "$stdout_file"
  assert_no_diff <( echo -n "" ) "$stderr_file"
}

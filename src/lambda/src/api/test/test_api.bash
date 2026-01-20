# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


_test.create_file() {
  local file_path
  file_path="$1"
  IFS= read -rd '' script || :
  echo "$script" > "$file_path" 
}

_test.run_lambda_rie() {
  # Start Lambda Runtime Interface Emulator in background
  aws-lambda-rie "${SCRIPT_DIR}/../bootstrap" >/dev/null 2>&1 &
  _AWS_LAMBDA_RIE_PID="$!"
  trap 'kill -s SIGTERM $_AWS_LAMBDA_RIE_PID' EXIT
  sleep 1
}

test_init_error_calls_http_post_with_correct_body_and_headers() {
  set -euo pipefail
  source "${SCRIPT_DIR}/../api.bash"

  __lambda.api.set_runtime_api_base_url "baseurl"

  local tmpdir
  tmpdir="$(mktemp -d)"

  # shellcheck disable=SC2064
  trap "rm -rf '$tmpdir'" EXIT

  # mock http.post
  local got_body
  local got_url

  __lambda.api.http.post() {
    IFS= read -rd '' body || : 
    got_body="$body"
    got_url="$1"
    got_headers=( "${@:2}" )
  } 

  local want_body
  want_body="${tmpdir}/want_body"
  _test.create_file "$want_body" <<EOF
{
  "errorMessage": "error_msg",
  "errorType": "myerrortype",
  "stackTrace": ["stacktrace1", "stacktrace2", "stacktrace3"] 
}
EOF

  
  __lambda.api.init_error "error_msg" "myerrortype" "stacktrace1" "stacktrace2" "stacktrace3"
  assert_no_diff "$want_body" <( echo "$got_body" )
  assert_equals "1" "${#got_headers[@]}"
  assert_equals "Content-Type: application/json" "${got_headers[0]}"
  assert_equals "$(__lambda.api.get_runtime_api_base_url)/runtime/init/error" "$got_url"
}

test_invocation_error_calls_http_post_with_correct_body_and_headers() {
  set -euo pipefail
  source "${SCRIPT_DIR}/../api.bash"

  __lambda.api.set_runtime_api_base_url "baseurl"

  local tmpdir
  tmpdir="$(mktemp -d)"

  # shellcheck disable=SC2064
  trap "rm -rf '$tmpdir'" EXIT

  # mock http.post
  local got_body
  local got_url

  __lambda.api.http.post() {
    IFS= read -rd '' body || : 
    got_body="$body"
    got_url="$1"
    got_headers=( "${@:2}" )
  } 

  local want_body
  want_body="${tmpdir}/want_body"
  _test.create_file "$want_body" <<EOF
{
  "errorMessage": "error_msg",
  "errorType": "myerrortype",
  "stackTrace": ["stacktrace1", "stacktrace2", "stacktrace3"] 
}
EOF

  
  __lambda.api.invocation_error "myrequestid" "error_msg" "myerrortype" "stacktrace1" "stacktrace2" "stacktrace3"
  assert_no_diff "$want_body" <( echo "$got_body" )
  assert_equals "1" "${#got_headers[@]}"
  assert_equals "Content-Type: application/json" "${got_headers[0]}"
  assert_equals "$(__lambda.api.get_runtime_api_base_url)/runtime/invocation/myrequestid/error" "$got_url"
}


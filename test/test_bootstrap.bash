# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

_test.run_lambda_rie() {
  # Start Lambda Runtime Interface Emulator in background
  aws-lambda-rie "${SCRIPT_DIR}/../bootstrap" >/dev/null 2>&1 &
  _AWS_LAMBDA_RIE_PID="$!"
  trap 'kill -s SIGTERM $_AWS_LAMBDA_RIE_PID' EXIT
  sleep 1
}

_test.set_handler() {
  local script
  local lambda_task_root
  local handler_function_name
  
  lambda_task_root="$1"
  handler_function_name="$2"

  # Read stdin
  IFS= read -rd '' script 

  # Create script file in lambda task root
  echo "$script" > "$lambda_task_root/script.bash"

  # set _HANDLER env var
  export _HANDLER="script.$handler_function_name"
}


test_bootstrap_runs_handler_function_when_event_is_received() ( 
  # Create tmpdir for lambda task root
  LAMBDA_TASK_ROOT="$(mktemp -d)"
  export LAMBDA_TASK_ROOT

  _test.set_handler "$LAMBDA_TASK_ROOT" "handler" <<EOF
  handler() {
    echo "ran!" 
  }
EOF

  _test.run_lambda_rie
  RESPONSE="$(curl -sSL -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{}')"
  assert_equals "ran!" "$RESPONSE"
)


test_bootstrap_passes_event_to_handler_on_stdin() ( 
  # Create tmpdir for lambda task root
  LAMBDA_TASK_ROOT="$(mktemp -d)"
  export LAMBDA_TASK_ROOT

  _test.set_handler "$LAMBDA_TASK_ROOT" "handler" <<'EOF'
  handler() {
    IFS= read -r -d '' event
    echo "$event" 
  }
EOF

  _test.run_lambda_rie

  local want_event
  local got_event
  want_event='{ "hello": "world" }'
  
  got_event="$(
    curl \
      -sSL \
      -XPOST \
      -d "$want_event" \
      "http://localhost:8080/2015-03-31/functions/function/invocations"
    )"
  assert_equals "$want_event" "$got_event"
)


test_bootstrap_passes_request_id_to_handler_as_env_var() ( 
  # Create tmpdir for lambda task root
  LAMBDA_TASK_ROOT="$(mktemp -d)"
  export LAMBDA_TASK_ROOT

  env_var_name="LAMBDA_RUNTIME_AWS_REQUEST_ID"
  _test.set_handler "$LAMBDA_TASK_ROOT" "handler" <<EOF
  handler() {
    while IFS= read -r env_var; do
      echo "\${env_var%%=*}"
    done < <( env | grep -E '^$env_var_name' )
  }
EOF

  _test.run_lambda_rie

  local want_event
  local got_event
 
  response="$(
    curl \
      -sSL \
      -XPOST \
      -d '{}' \
      "http://localhost:8080/2015-03-31/functions/function/invocations"
    )"
  assert_equals "$env_var_name" "$response"
)


test_bootstrap_passes_runtime_deadline_as_env_var() ( 
  # Create tmpdir for lambda task root
  LAMBDA_TASK_ROOT="$(mktemp -d)"
  export LAMBDA_TASK_ROOT

  env_var_name="LAMBDA_RUNTIME_DEADLINE_MS"
  _test.set_handler "$LAMBDA_TASK_ROOT" "handler" <<EOF
  handler() {
    while IFS= read -r env_var; do
      echo "\${env_var%%=*}"
    done < <( env | grep -E '^$env_var_name' )
  }
EOF

  _test.run_lambda_rie

  local want_event
  local got_event
 
  response="$(
    curl \
      -sSL \
      -XPOST \
      -d '{}' \
      "http://localhost:8080/2015-03-31/functions/function/invocations"
    )"
  assert_equals "$env_var_name" "$response"
)





########## START library api.bash ###########
__lambda.api.get_runtime_api_base_url() {
  echo "$__LAMBDA_RUNTIME_API_BASE_URL"
}

__lambda.api.set_runtime_api_base_url() {
  local base_url
  base_url="$1"
  export __LAMBDA_RUNTIME_API_BASE_URL="$base_url"
}


__lambda.api.next_invocation() {
  __lambda.api.http.get "$(__lambda.api.get_runtime_api_base_url)/runtime/invocation/next"
}

__lambda.api.invocation_response() {
  local aws_request_id
  aws_request_id="$1"
  echo -n "" | __lambda.api.http.post \
    "$(__lambda.api.get_runtime_api_base_url)/runtime/invocation/$aws_request_id/response" \
    "Content-Type: application/json"
}

# args:
#   1: error_message
#   2: error_type
#   3-n: stacktrace lines
__lambda.api.init_error() {
  local error_message 
  local error_type
  local -a stacktrace

  error_message="$1"
  error_type="$2"
  stacktrace=( "${@:3}" )

  __lambda.api.http.post \
    "$(__lambda.api.get_runtime_api_base_url)/runtime/init/error" \
    "Content-Type: application/json" \
    >/dev/null \
<<EOF
{
  "errorMessage": "$error_message",
  "errorType": "$error_type",
  "stackTrace": [$(  length="${#stacktrace[@]}"
                   last_index=$(( length - 1))
                   for trace_index in "${!stacktrace[@]}"; do
                     if (( trace_index == last_index )); then
                        echo -n "\"${stacktrace[trace_index]}\""
                     else
                        echo -n "\"${stacktrace[trace_index]}\", "
                     fi
                   done )] 
}
EOF
}


# args:
#   1: aws_request_id
#   2: error_message
#   3: error_type
#   4-n: stacktrace lines
__lambda.api.invocation_error() {
  local aws_request_id
  local error_message 
  local error_type
  local -a stacktrace

  aws_request_id="$1"
  error_message="$2"
  error_type="$3"
  stacktrace=( "${@:4}" )

  __lambda.api.http.post \
    "$(__lambda.api.get_runtime_api_base_url)/runtime/invocation/$aws_request_id/error" \
    "Content-Type: application/json" \
    >/dev/null \
<<EOF
{
  "errorMessage": "$error_message",
  "errorType": "$error_type",
  "stackTrace": [$(  length="${#stacktrace[@]}"
                   last_index=$(( length - 1))
                   for trace_index in "${!stacktrace[@]}"; do
                     if (( trace_index == last_index )); then
                        echo -n "\"${stacktrace[trace_index]}\""
                     else
                        echo -n "\"${stacktrace[trace_index]}\", "
                     fi
                   done )] 
}
EOF
}
########## END library api.bash ###########


__lambda.handle_invocation_response() {
  # read status code line
  IFS=' ' read -r _ status_code _
  if [[ "$status_code" != "200" ]]; then
    echo -n "ERROR: status code of invocation response was not 200. Got code '$status_code'" >&2
    return 1
  fi

  "$__LAMBDA_EVENT_HANDLER_FUNCTION"
}

__lambda.set_event_handler_function() {
  event_handler_function="$1"
  export "__LAMBDA_EVENT_HANDLER_FUNCTION=$event_handler_function"
}


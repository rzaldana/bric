
source ./api/api.bash

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


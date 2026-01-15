#!/usr/bin/env bash

__bootstrap_export_header() {
  local header_key="$1"
  local header_value
  echo "header_key is $header_key" >&2
  header_value="$(
    grep --fixed-strings --ignore-case "$header_key" \
    | tr --delete '[:space:]' \
    | cut --delimiter ':' --fields 2
    )"

  echo "header value is $header_value"

  local env_var_name
  # make all chars in header key upper case
  env_var_name="${header_key^^}"
  # replace all dashes with underscores
  env_var_name="${env_var_name//-/_}"
  # add underscore to beginning of name
  env_var_name="_${env_var_name}"
  echo "${env_var_name}"="${header_value}"
  export "${env_var_name}"="${header_value}"
}

__bootstrap_export_header "Lambda-Runtime-Aws-Request-Id"


# Sends a GET http request
# Sends response body and headers to stdout
__lambda.api.http.get() {
  local url
  url="$1"
  curl \
    --request GET \
    --silent \
    --show-error \
    --location \
    --dump-header "-" \
    --fail \
    "$url"
}


# Sends a POST http request
# Reads requests' body from stdin
# Sends response body and headers to stdout
# args:
#  1: url
#  2-n: headers in the form "header: value"
__lambda.api.http.post() {
  local url
  url="$1"
  local -a headers
  headers=( "${@:2}" )

  curl \
    --request POST \
    --silent \
    --show-error \
    --location \
    --dump-header "-" \
    --fail \
    --data "@-" \
    --header "@"<( for header in "${headers[@]}"; do echo "$header"; done ) \
    "$url"
}

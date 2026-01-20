#!/usr/bin/env bash

set -euo pipefail

IFS= read -rd'' status_code_line || :
echo "status_code_line=$status_code_line"

#if ! IFS= read -rd'' status_code_line; then
#  echo -n "ERROR: Unable to read invocation response. Got response: '$status_code_line'"
#fi

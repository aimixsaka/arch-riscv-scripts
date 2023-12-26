#!/usr/bin/bash
set -e

[[ -n "$UTIL_SOURCE_SH" ]] && return
UTIL_SOURCE_SH=1

_DEVTOOLS_LIBRARY_DIR=${_DEVTOOLS_LIBRARY_DIR:-/usr/share/devtools}
#shellcheck source=/usr/share/devtools/lib/common.sh
source "${_DEVTOOLS_LIBRARY_DIR}"/lib/common.sh

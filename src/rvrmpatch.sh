#!/usr/bin/bash

##
# remove patch then commit and push
##

# scripts source dir
_RV_SOURCE_DIR=${_RV_SOURCE_DIR:-$(dirname -- $(realpath -- "${BASH_SOURCE[0]}"))}
source "${_RV_SOURCE_DIR}/util.sh"
source "${_RV_SOURCE_DIR}/config.sh"

patch_name=""

usage() {
  cat <<- _EOF_
    Usage: ${BASH_SOURCE[0]##*/} [patch_name]

    Remove patch from '\$RV_PATCH_REPO', then commit and push this change

    Options:
        -h, --help      Show this help
_EOF_
  exit 0
}

(( $# > 1 )) && usage

while (( $# )); do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -*)
			die "invalid argument: %s" "$1"
			;;
		*)
			break
			;;
  esac
done

if [[ -n "$1" ]]; then
  patch_name="$1"
else
  patch_name="$(basename -- "$(pwd -P)")"
fi

cd "$RV_PATCH_REPO" || die "cd $RV_PATCH_REPO failed"
git pull origin master

[[ -d "./$patch_name" ]] || die "$patch_name doesn't exist in $RV_PATCH_REPO"
git checkout origin/master && git checkout -b "$patch_name"
rm -rf "$patch_name" && git add . && git commit --no-gpg-sign && git push --set-upstream origin "$patch_name"

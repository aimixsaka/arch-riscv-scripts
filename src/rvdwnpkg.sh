#!/usr/bin/bash
set -e

##
# Download x64 pkg and change arch array if needed.
##

# scripts source dir
_RV_SOURCE_DIR=${_RV_SOURCE_DIR:-$(dirname -- $(realpath -- "$0"))}
source "${_RV_SOURCE_DIR}/config.sh"
source "${_RV_SOURCE_DIR}/util.sh"

force_download=0
pkgctl_args=()

usage() {
  echo "Usage: ${0##*/} [options] pkgname -- [pkgctl arguments]"
  echo 'Download x64 package source from gitlab'
  echo
  echo ' options:'
  echo '    -h    this help'
  echo '    -f    force download again though already exist'
  exit 0
}

while getopts "fh" arg; do
  case "$arg" in
    f) 
      force_download=1
      ;;
    h|?)
      usage 
      ;;
    *) 
      error "invalid argument '%s'" "$arg";
      usage 
      ;;
  esac
done
shift $(( OPTIND - 1 ))

(( $# < 1 )) && die 'You must specify a pkgname.'
pkgname="$1"

if [[ -d "$pkgname" ]]; then
  (( force_download )) && rm -rf "$pkgname" ||
    die "$pkgname already exist"
fi
pkgctl_args+=("${@:3}")
pkgctl repo clone --protocol=https "${pkgctl_args[@]}" "$pkgname"


cd "$pkgname"
# checkout to latest_tag
git fetch --tags
latest_tag="$(git describe --tags "$(git rev-list --tags --max-count=1)")"
git checkout "$latest_tag"

# import gpg key if exists
[[ -d ./keys ]] && gpg --import ./keys/pgp/*

# patch PKGBUILD
! grep -E -q '^arch=\(.*?(any|riscv64).*?\)' PKGBUILD && 
  sed -i -E -e 's|^arch=\((.*)\)|arch=\(\1 riscv64\)|' PKGBUILD


# copy patch from riscv repository if have
[[ -d "$RV_PATCH_REPO/$pkgname" ]] &&
  cp -r "$RV_PATCH_REPO/$pkgname" "orig-patches" &&
  cp -r orig-patches/* . && 
  patch -i riscv64.patch

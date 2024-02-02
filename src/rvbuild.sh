#!/usr/bin/bash

set -e

##
# Build riscv package.
##

# scripts source dir
_RV_SOURCE_DIR=${_RV_SOURCE_DIR:-$(dirname -- $(realpath -- "${BASH_SOURCE[0]}"))}
source "${_RV_SOURCE_DIR}/config.sh"
source "${_RV_SOURCE_DIR}/util.sh"

extra_riscv_build_args=()

[[ ! -e ./PKGBUILD ]] && die "No PKGBUILD in current directory"

usage() {
  local -r COMMAND=${BASH_SOURCE[0]##*/}
  cat <<- _EOF_
    Usage: ${COMMAND} [OPTIONS] -- [extra-riscv64-build options]
    
    Build RISC V package.

    OPTIONS
        -h, --help              this help
        -C, --cache CACHE_DIR   set makechrootpkg cache dir
        -d, --dir   DIR_NAME    send to makechrootpkg -l 
        -c, --clean             means "extra-riscv64-build -c"

    Default extra-riscv64-build args: -- -d "\$RV_CACHE:/var/cache/pacman/pkg" [-l \$RV_ROOT]
_EOF_
}

while (( $# )); do
  case $1 in 
    -h|--help) 
      usage
      exit 0
      ;;
    -C|--cache)
      RV_CACHE=$2
      shift 2
      ;;
    -d|--dir)
      RV_ROOT=$2
      shift 2
      ;;
    -c|--clean)
      extra_riscv_build_args+=('-c')
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      die "invalid argument: %s" "$1"
      ;;
    *)
      break
      ;;
  esac
done

[[ -n "$RV_CACHE" ]] || die "Must set pacman cache dir"

# set defautl extra-riscv64-build args
extra_riscv_build_args+=(
  '--' 
  '-d' "$RV_CACHE:/var/cache/pacman/pkg"
)
# change the chroot dir to $RV_ROOT if set
[[ -n "$RV_ROOT" ]] && extra_riscv_build_args+=('-l' "$RV_ROOT")

(( $# > 0 )) && extra_riscv_build_args=("$@")

extra-riscv64-build "${extra_riscv_build_args[@]}"

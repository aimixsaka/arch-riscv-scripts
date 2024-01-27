#!/usr/bin/bash
set -e

##
# Create patches and move them to 'patch' dir,
# consumed by 'rvmkpr'
# Usage: rvmkpatch [pkg_dir]
#        'pkg_dir' default to current directory.
##

# scripts source dir
_RV_SOURCE_DIR=${_RV_SOURCE_DIR:-$(dirname -- $(realpath -- "${BASH_SOURCE[0]}"))}
source "${_RV_SOURCE_DIR}/util.sh"
source "${_RV_SOURCE_DIR}/config.sh"

pkg_dir="$(realpath -- "$(pwd -P)")"
patch_dir="$pkg_dir/patch"
pkgname="$(basename -- "$pkg_dir")"


# restore arch array if modified
sed -i -E -e 's|^arch=\((.*?)( riscv64)+\)|arch=\(\1\)|' PKGBUILD


[[ ! -e ./PKGBUILD ]] && die "No PKGBUILD in current directory"
# shellcheck disable=1091
. "$pkg_dir/PKGBUILD"

[[ -d "$patch_dir" ]] || msg "Creating patch_dir $patch_dir" &&
  mkdir -p "$patch_dir"

# copy patches to patch/ dir
# shellcheck disable=2154
for patch in ${source[@]}; do
  [[ -e "$patch" ]] && [[ "$patch" != LICNSE ]] && cp -rv "$patch" "$patch_dir/"
done


# creat riscv64.patch
git diff --no-prefix PKGBUILD | tail -n +3 > "$patch_dir/riscv64.patch"

# remain riscv64 in arch array after making patch
! grep -E -q '^arch=\(.*?(any|riscv64).*?\)' PKGBUILD &&
  sed -i -E -e 's|^arch=\((.*)\)|arch=\(\1 riscv64\)|' PKGBUILD

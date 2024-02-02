#!/usr/bin/bash
set -e

##
# create riscv package patch with patches in pkgdir/patch/*
# rvmkpatch pkgdir
##

# scripts source dir
_RV_SOURCE_DIR=${_RV_SOURCE_DIR:-$(dirname -- $(realpath -- "${BASH_SOURCE[0]}"))}
source "${_RV_SOURCE_DIR}/util.sh"
source "${_RV_SOURCE_DIR}/config.sh"

usage() {
  local -r COMMAND="${0##*/}"
  cat <<- _EOF_
    Usage: ${COMMAND} [OPTIONS]

    Sync patches from current-dir/patch/ to \$RV_PATCH_REPO/pkgname/.

    OPTIONS:
        -h      Show this help
_EOF_
}

# more functional, won't be affected by envs :-)
sync_patches() {
  local patch_dir patch_repo pkgname
  patch_dir="$1"
  patch_repo="$2"
  pkgname="$3"
  
  pushd "$patch_repo" &>/dev/null
  msg 'Reset all files to origin/master...'
  git restore --staged '*'
  git reset --hard master
  git clean -ff
  git checkout master
  msg 'Updating local master branch...'
  git pull
  # git branch | grep -q "$pkgname" && git branch -d "$pkgname"
  # git branch -vv | grep -q "origin/$pkgname" && git push origin -d "origin/$pkgname"
  git branch | grep -q "$pkgname" && git switch "$pkgname" ||
    git switch -c "$pkgname"
  [[ -d "$pkgname" ]] || mkdir "$pkgname"

  rsync -rv --delete "$patch_dir/" "$patch_repo/$pkgname/"

  git add . 
  commit_num=$(git rev-list --count master.."$pkgname")
  if (( commit_num == 1 )); then
    git commit --no-gpg-sign --amend
    git push -f --set-upstream origin "$pkgname"
  elif (( commit_num == 0 )); then
    git commit --no-gpg-sign 
    git push --set-upstream origin "$pkgname"
  else
    die "branch [$pkgname] ahead of master too much!"
  fi
  popd &>/dev/null
}

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

pkg_dir="$(realpath -- "$(pwd -P)")"
patch_dir="$pkg_dir/patch"
pkgname="$(basename -- "$pkg_dir")"

# check existence of patch dir 
[[ -d "$patch_dir" ]] || die "$(dirname -- "$patch_dir") doesn't contain a 'patch' directory"

sync_patches "$patch_dir" "$RV_PATCH_REPO" "$pkgname"

#!/usr/bin/env bash
# ==========================================================================
#  Where - build the macOS release files
#
#    build-macos.sh           universal binary (Apple Silicon + Intel)
#    build-macos.sh --native  build for this machine's CPU only (faster)
#    build-macos.sh --help    show this help
#
#  Produces in dist/v<version>/:
#    Where-<version>-macos-universal.dmg
#    Where-<version>-macos-universal.zip
#
#  Requires: Rust (cargo), Flutter (stable), Xcode command-line tools.
#    brew install --cask flutter        (if Flutter not installed)
#    xcode-select --install             (if Xcode CLI tools not installed)
# ==========================================================================
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

for arg in "$@"; do
  case "$arg" in
    --help|-h) sed -n '2,15p' "$0"; exit 0 ;;
  esac
done

VERSION="$(sed -n 's/^version = "\(.*\)"/\1/p' Cargo.toml | head -1)"
TAG="v$VERSION"

printf '\n  \033[1;97mW H E R E\033[0m   build %s — macOS\n' "$VERSION"
printf '  \033[90m---------------------------------------------------\033[0m\n\n'

# Flags for package.sh
FLAGS="--archive"
for arg in "$@"; do
  case "$arg" in
    --native) ;;
    *) FLAGS="--universal --archive" ;;
  esac
done
# Default to universal if no args
if [[ $# -eq 0 ]]; then
  FLAGS="--universal --archive"
fi

bash scripts/package.sh $FLAGS

printf '\n  \033[92mOK\033[0m  Done\n'
printf '  Files in  dist/%s/\n\n' "$TAG"
ls "dist/$TAG/" 2>/dev/null || ls dist/ 2>/dev/null || true
printf '\n'

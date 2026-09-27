#!/usr/bin/env bash
# ==========================================================================
#  Where - build the Linux release files
#
#    build-linux.sh           build for this machine's architecture
#    build-linux.sh --help    show this help
#
#  Produces in dist/v<version>/ (x64 example):
#    Where-<version>-linux-x64.AppImage
#    Where-<version>-linux-x64.deb
#    Where-<version>-linux-x64.tar.gz
#
#  Requires:
#    Rust (cargo), Flutter (stable), clang, cmake, ninja, pkg-config,
#    libgtk-3-dev, liblzma-dev, libstdc++-12-dev, appimagetool.
#
#  Install dependencies on Ubuntu / Debian / Mint:
#    sudo apt-get install -y clang cmake ninja-build pkg-config \
#         libgtk-3-dev liblzma-dev libstdc++-12-dev
#
#  appimagetool (needed for .AppImage):
#    ARCH=$([ "$(uname -m)" = x86_64 ] && echo x86_64 || echo aarch64)
#    curl -fsSL -o ~/appimagetool \
#      "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$ARCH.AppImage"
#    chmod +x ~/appimagetool
#    export APPIMAGETOOL=~/appimagetool
#    export APPIMAGE_EXTRACT_AND_RUN=1   # runners without FUSE
# ==========================================================================
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

for arg in "$@"; do
  case "$arg" in
    --help|-h) sed -n '2,32p' "$0"; exit 0 ;;
  esac
done

VERSION="$(sed -n 's/^version = "\(.*\)"/\1/p' Cargo.toml | head -1)"
TAG="v$VERSION"
ARCH="$(uname -m)"
case "$ARCH" in x86_64|amd64) ARCH=x64 ;; arm64|aarch64) ARCH=arm64 ;; esac

printf '\n  \033[1;97mW H E R E\033[0m   build %s — Linux %s\n' "$VERSION" "$ARCH"
printf '  \033[90m---------------------------------------------------\033[0m\n\n'

# Check for appimagetool if not already set
if [[ -z "${APPIMAGETOOL:-}" ]]; then
  if command -v appimagetool >/dev/null 2>&1; then
    export APPIMAGETOOL="$(command -v appimagetool)"
  else
    printf '  \033[93m!!\033[0m  appimagetool not found — .AppImage will be skipped.\n'
    printf '  \033[90m    See the header of this script for install instructions.\033[0m\n\n'
  fi
fi

# Enable Flutter desktop
flutter config --no-analytics --enable-linux-desktop >/dev/null 2>&1 || true

bash scripts/package.sh --archive

printf '\n  \033[92mOK\033[0m  Done\n'
printf '  Files in  dist/%s/\n\n' "$TAG"
ls "dist/$TAG/" 2>/dev/null || ls dist/ 2>/dev/null || true
printf '\n'

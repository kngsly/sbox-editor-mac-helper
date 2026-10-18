#!/bin/sh
# Clones Facepunch/sbox-public at a pinned commit and runs its own Setup.sh (Apple Silicon only).
# The pin matters: Setup.sh downloads prebuilt macOS arm64 native libraries that must match the
# managed code. Updating managed code alone produces an interop mismatch.
#   SBOX_COMMIT   commit to build (default: the one this repo was tested with)
#   SBOX_DIR      checkout location (default: ~/sbox-public)
#   SBOX_DOTNET_ROOT  private dotnet from install-dotnet.sh (default ~/.sbox-dotnet)
set -eu
SBOX_COMMIT="${SBOX_COMMIT:-0de6fc3}"
SBOX_DIR="${SBOX_DIR:-$HOME/sbox-public}"
export DOTNET_ROOT="${SBOX_DOTNET_ROOT:-$HOME/.sbox-dotnet}"
export DOTNET_ROOT_ARM64="$DOTNET_ROOT"
export PATH="$DOTNET_ROOT:$PATH"
here="$(cd "$(dirname "$0")/.." && pwd)"

[ -d "$SBOX_DIR/.git" ] || git clone https://github.com/Facepunch/sbox-public.git "$SBOX_DIR"
cd "$SBOX_DIR"
git fetch origin
git checkout "$SBOX_COMMIT"
# Optional but recommended: stop rendering fully covered windows (see docs/findings.md).
if [ "${APPLY_OCCLUSION_PATCH:-1}" = 1 ]; then
  git apply --check "$here/patches/skip-render-when-occluded.patch" 2>/dev/null \
    && git apply "$here/patches/skip-render-when-occluded.patch" \
    || echo "occlusion patch skipped (already applied or does not apply to $SBOX_COMMIT)"
fi
./Setup.sh

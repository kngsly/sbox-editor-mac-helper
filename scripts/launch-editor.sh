#!/bin/sh
# Starts the s&box editor (sbox-dev) from the checkout made by setup-engine.sh.
# Steam must be running and signed in: the engine calls SteamAPI_Init (AppID 590830).
set -eu
export DOTNET_ROOT="${SBOX_DOTNET_ROOT:-$HOME/.sbox-dotnet}"
export DOTNET_ROOT_ARM64="$DOTNET_ROOT"
export PATH="$DOTNET_ROOT:$PATH"
cd "${SBOX_DIR:-$HOME/sbox-public}/game"
exec ./sbox-dev "$@"

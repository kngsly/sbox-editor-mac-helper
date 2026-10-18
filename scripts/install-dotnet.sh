#!/bin/sh
# Installs a private .NET 10 SDK into ~/.sbox-dotnet so it does not touch a system dotnet.
# Used versions on the reference machine: SDK 10.0.401, runtime 10.0.12.
set -eu
DOTNET_ROOT="${SBOX_DOTNET_ROOT:-$HOME/.sbox-dotnet}"
curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
sh /tmp/dotnet-install.sh --channel 10.0 --install-dir "$DOTNET_ROOT"
"$DOTNET_ROOT/dotnet" --list-sdks

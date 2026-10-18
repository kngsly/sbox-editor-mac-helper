#!/bin/sh
# Builds a Dock-able "s&box Launcher.app" in ~/Applications that runs game/sbox-launcher
# (the project browser / launcher) from the checkout. Pass --editor for sbox-dev instead.
set -eu
target=sbox-launcher; [ "${1:-}" = "--editor" ] && target=sbox-dev
app="${APP_DIR:-$HOME/Applications}/s&box Launcher.app"
dotnet_root="${SBOX_DOTNET_ROOT:-$HOME/.sbox-dotnet}"
sbox_dir="${SBOX_DIR:-$HOME/sbox-public}"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key><string>local.sbox.launcher</string>
    <key>CFBundleName</key><string>s&amp;box Launcher</string>
    <key>CFBundleDisplayName</key><string>s&amp;box Launcher</string>
    <key>CFBundleExecutable</key><string>sbox-launcher</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST
cat > "$app/Contents/MacOS/sbox-launcher" <<EOS
#!/bin/sh
set -eu
export DOTNET_ROOT="$dotnet_root"
export DOTNET_ROOT_ARM64="\$DOTNET_ROOT"
export PATH="\$DOTNET_ROOT:\$PATH"
cd "$sbox_dir/game"
exec ./$target "\$@"
EOS
chmod +x "$app/Contents/MacOS/sbox-launcher"
echo "Created $app (runs $target). Drag it to the Dock."

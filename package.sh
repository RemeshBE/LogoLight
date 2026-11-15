#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
stage="$(mktemp -d "${TMPDIR:-/tmp}/LogoLichtPkg.XXXXXXXX")"
trap 'rm -rf -- "$stage"' EXIT
root="$stage/root"
mkdir -p "$root/Applications" "$root/Library/LaunchDaemons" "$root/Library/PrivilegedHelperTools" "$stage/scripts"
bash build.sh
ditto -x -k build/LogoLicht-macOS.zip "$stage"
app="$stage/LogoLicht.app"
install -m 755 "$app/Contents/MacOS/LogoHelper" "$root/Library/PrivilegedHelperTools/local.logolicht.mac.control"
rm "$app/Contents/MacOS/LogoHelper" "$app/Contents/Library/LaunchDaemons/local.logolicht.mac.control.plist"
codesign --force --sign - "$app"
ditto "$app" "$root/Applications/LogoLight.app"
cat > "$root/Library/LaunchDaemons/local.logolicht.mac.control.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>local.logolicht.mac.control</string>
    <key>Program</key><string>/Library/PrivilegedHelperTools/local.logolicht.mac.control</string>
    <key>MachServices</key><dict><key>local.logolicht.mac.control</key><true/></dict>
</dict>
</plist>
PLIST
cat > "$stage/scripts/preinstall" <<'SCRIPT'
#!/bin/bash
set -eu
[[ "$3" == "/" ]] || exit 1
old="/Applications/LogoLicht.app"
new="/Applications/LogoLight.app"
if [[ -d "$old" && ! -L "$old" && ! -e "$new" && ! -L "$new" ]] &&
   [[ "$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$old/Contents/Info.plist" 2>/dev/null)" == local.logolicht.mac ]]; then
    /bin/mv "$old" "$new"
fi
case "$(/usr/sbin/sysctl -n hw.model)" in
    Mac17,10|Mac17,11|Mac17,12|Mac17,13) ;;
    *) echo "LogoLicht vereist een MacBook Pro met PROLED XDR-display." >&2; exit 1 ;;
esac
SCRIPT
cat > "$stage/scripts/postinstall" <<'SCRIPT'
#!/bin/bash
set -eu
service=local.logolicht.mac.control
plist="/Library/LaunchDaemons/$service.plist"
/bin/launchctl bootout "system/$service" 2>/dev/null || true
/bin/launchctl bootstrap system "$plist"
SCRIPT
chmod 755 "$stage/scripts/"*
plutil -lint "$root/Library/LaunchDaemons/"*.plist
codesign --verify --strict "$root/Applications/LogoLight.app"
pkgbuild --root "$root" --ownership recommended --component-plist components.plist \
    --scripts "$stage/scripts" --identifier local.logolicht.mac.installer --version 25.2 \
    --install-location / build/LogoLight-25.2.pkg

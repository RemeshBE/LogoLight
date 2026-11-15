#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

stage="$(mktemp -d "${TMPDIR:-/tmp}/LogoLicht.XXXXXXXX")"
trap 'rm -rf -- "$stage"' EXIT
app="$stage/LogoLicht.app"
launch="$app/Contents/Library/LaunchDaemons"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources" "$launch" "$stage/LogoLicht.iconset" build
cp Info.plist "$app/Contents/Info.plist"
cp local.logolicht.mac.control.plist "$launch/"

compiler=(/usr/bin/xcrun --sdk macosx swiftc -swift-version 5 -module-cache-path "$stage/ModuleCache" -target arm64-apple-macos14.0)
"${compiler[@]}" Icon.swift -o "$stage/DrawIcon"
"$stage/DrawIcon" "$stage/LogoLicht.iconset" "$app/Contents/Resources/LogoLicht.icns"
"${compiler[@]}" -parse-as-library -O -import-objc-header Membership.h Helper.swift LogoService.swift -o "$app/Contents/MacOS/LogoHelper"
"${compiler[@]}" -parse-as-library -O LogoLicht.swift LogoService.swift Language.swift Schedule.swift ShortcutImport.swift TermsPanel.swift Automation.swift -o "$app/Contents/MacOS/LogoLicht"

/usr/bin/codesign --force --sign "${LOGOLICHT_SIGN_IDENTITY:--}" "$app/Contents/MacOS/LogoHelper"
/usr/bin/codesign --force --sign "${LOGOLICHT_SIGN_IDENTITY:--}" "$app"
/usr/bin/codesign --verify --deep --strict "$app"
/usr/bin/ditto -c -k --keepParent "$app" "$stage/LogoLicht-macOS.zip"
mv -f "$stage/LogoLicht-macOS.zip" build/
cp "$stage/LogoLicht.iconset/icon_512x512.png" build/LogoLicht-icoon.png

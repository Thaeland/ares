#!/bin/sh
# Type-checks the macOS runner's Swift against the real macOS SDK and a stub
# FlutterMacOS module (declarations only). This is a compile check of the
# runner sources, not an app build: no engine, plugins or bundle.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
out=${TMPDIR:-/tmp}/ares-macos-typecheck
rm -rf "$out"
mkdir -p "$out"
sdk=$(xcrun --sdk macosx --show-sdk-path)
target=${ARES_MACOS_TARGET:-arm64-apple-macos13.0}
xcrun swiftc -sdk "$sdk" -target "$target" -parse-as-library \
  -emit-module -module-name FlutterMacOS \
  -emit-module-path "$out/FlutterMacOS.swiftmodule" \
  "$here/flutter_macos_stub.swift"
xcrun swiftc -sdk "$sdk" -target "$target" -typecheck -I "$out" \
  -warnings-as-errors \
  "$root/macos/Runner/AresDesktopOS.swift" \
  "$root/macos/Runner/AppDelegate.swift" \
  "$root/macos/Runner/MainFlutterWindow.swift" \
  "$here/macos_stub_registrant.swift"
echo "macOS runner Swift type-checks ($target)"

#!/bin/sh
# Type-checks ios/Runner/SceneDelegate.swift (keep-awake and hermes:// deep
# link channels) against the real iOS SDK and a stub Flutter module
# (declarations only). A compile check of the runner source, not an app build.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
out=${TMPDIR:-/tmp}/ares-ios-typecheck
rm -rf "$out"
mkdir -p "$out"
sdk=$(xcrun --sdk iphonesimulator --show-sdk-path)
target=${ARES_IOS_TARGET:-arm64-apple-ios15.0-simulator}
xcrun swiftc -sdk "$sdk" -target "$target" -parse-as-library \
  -emit-module -module-name Flutter \
  -emit-module-path "$out/Flutter.swiftmodule" \
  "$here/flutter_ios_stub.swift"
xcrun swiftc -sdk "$sdk" -target "$target" -typecheck -I "$out" \
  -warnings-as-errors \
  "$root/ios/Runner/SceneDelegate.swift" \
  "$here/ios_stub_shared.swift"
echo "iOS SceneDelegate Swift type-checks ($target)"

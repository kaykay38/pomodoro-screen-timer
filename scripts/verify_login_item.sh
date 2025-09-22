#!/usr/bin/env bash
set -euo pipefail

SCHEME="${SCHEME:-Pomodoro Screen Timer}"
CONFIGURATION="${CONFIGURATION:-Debug}"
APP_NAME="${APP_NAME:-Pomodoro Screen Timer}"

echo "== Discovering build folder =="
BUILD_DIR=$(
  xcodebuild -showBuildSettings \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -sdk macosx \
    -destination 'generic/platform=macOS' \
    -quiet 2>/dev/null \
  | sed -n 's/^ *CONFIGURATION_BUILD_DIR = //p' | head -n1
)
if [ -z "$BUILD_DIR" ]; then
  echo "ERROR: Could not determine CONFIGURATION_BUILD_DIR"; exit 2
fi
echo "Build Dir: $BUILD_DIR"

APP="$BUILD_DIR/$APP_NAME.app"
echo "App: $APP"
if [ ! -d "$APP" ]; then
  echo "ERROR: App bundle not found. Build first or check SCHEME/CONFIGURATION/APP_NAME."; exit 3
fi

HELPER="$APP/Contents/Library/LoginItems/LoginItemHelper.app"
echo "== Checking embedded login item =="
echo "Helper path: $HELPER"
if [ ! -d "$HELPER" ]; then
  echo "ERROR: Missing LoginItemHelper at expected path."; exit 4
fi
echo "OK: LoginItemHelper is embedded."

echo "== Reading bundle identifiers =="
MAIN_ID=$(defaults read "$APP/Contents/Info" CFBundleIdentifier 2>/dev/null || true)
HELPER_ID=$(defaults read "$HELPER/Contents/Info" CFBundleIdentifier 2>/dev/null || true)

if [ -z "$MAIN_ID" ] || [ -z "$HELPER_ID" ]; then
  echo "ERROR: Could not read one or both CFBundleIdentifier values."; exit 5
fi
echo "Main ID:   $MAIN_ID"
echo "Helper ID: $HELPER_ID"

# Optional expectations (set via env for CI)
MAIN_ID_EXPECT="${MAIN_ID_EXPECT:-$MAIN_ID}"
HELPER_ID_EXPECT="${HELPER_ID_EXPECT:-${MAIN_ID_EXPECT}.LoginItemHelper}"

echo "== Verifying IDs =="
if [ "$MAIN_ID" != "$MAIN_ID_EXPECT" ]; then
  echo "ERROR: Main ID mismatch. Expected: $MAIN_ID_EXPECT"; exit 6
fi
if [ "$HELPER_ID" != "$HELPER_ID_EXPECT" ]; then
  echo "ERROR: Helper ID mismatch. Expected: $HELPER_ID_EXPECT"; exit 7
fi

echo "All good."

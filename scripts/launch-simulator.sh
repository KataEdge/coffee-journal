#!/bin/bash
set -e

echo "🚀 Launching CoffeeJournal Simulator..."

# 1. Option to checkout/fetch main
FETCH_MAIN=true

if [ "$FETCH_MAIN" = true ]; then
  echo "📥 Fetching latest main branch..."
  git fetch origin main || true
fi

TARGET_ARG="$1"
DEVICE_ID=""

# 2. Determine target device ID
if [ -n "$TARGET_ARG" ]; then
  echo "🔍 Looking up specified device/ID: '$TARGET_ARG'..."
  DEVICE_ID=$(xcrun simctl list devices | grep -F "$TARGET_ARG" | head -n 1 | sed -E 's/.*\(([0-9A-F-]+)\).*/\1/')
  if [ -z "$DEVICE_ID" ]; then
    echo "⚠️  Warning: Specified device '$TARGET_ARG' not found. Falling back to auto-selection."
  fi
fi

# Check saved .simulator_id if no CLI target specified
if [ -z "$DEVICE_ID" ] && [ -f ".simulator_id" ]; then
  SAVED_ID=$(cat .simulator_id 2>/dev/null | tr -d '[:space:]')
  if [ -n "$SAVED_ID" ] && xcrun simctl list devices | grep -q "$SAVED_ID"; then
    DEVICE_ID="$SAVED_ID"
    echo "📌 Reusing saved simulator ID from .simulator_id: $DEVICE_ID"
  fi
fi

# If still no DEVICE_ID, find an unbooted (Shutdown) iPhone simulator to avoid conflicts with other agents
if [ -z "$DEVICE_ID" ]; then
  echo "📱 Searching for an unbooted iPhone simulator to avoid agent conflicts..."
  DEVICE_ID=$(xcrun simctl list devices available | grep -E "iPhone" | grep "Shutdown" | head -n 1 | sed -E 's/.*\(([0-9A-F-]+)\).*/\1/')

  if [ -z "$DEVICE_ID" ]; then
    echo "⚠️  No shutdown iPhone found. Falling back to any available iPhone simulator..."
    DEVICE_ID=$(xcrun simctl list devices available | grep -E "iPhone" | head -n 1 | sed -E 's/.*\(([0-9A-F-]+)\).*/\1/')
  fi
fi

if [ -z "$DEVICE_ID" ]; then
  echo "❌ Error: Could not find any iPhone simulator."
  exit 1
fi

# Ensure device is booted
IS_BOOTED=$(xcrun simctl list devices booted | grep -F "$DEVICE_ID" || true)
if [ -z "$IS_BOOTED" ]; then
  echo "⚡ Booting simulator ($DEVICE_ID)..."
  xcrun simctl boot "$DEVICE_ID" || true
else
  echo "⚡ Simulator ($DEVICE_ID) is already booted."
fi

# Save DEVICE_ID for future runs in this worktree
echo "$DEVICE_ID" > .simulator_id
echo "📱 Target Simulator ID: $DEVICE_ID (saved to .simulator_id)"

# 3. Open Simulator App
open -a Simulator

# 4. Build App
echo "🔨 Building CoffeeJournal for iphonesimulator..."
if [ -d "CoffeeJournal.xcodeproj" ]; then
  xcodebuild -project CoffeeJournal.xcodeproj -scheme CoffeeJournal -sdk iphonesimulator -destination "id=$DEVICE_ID" -derivedDataPath ./build build
  APP_PATH="./build/Build/Products/Debug-iphonesimulator/CoffeeJournal.app"
  BUNDLE_ID="com.antigravity.CoffeeJournal"
else
  xcodebuild -scheme CoffeeJournalApp -destination "id=$DEVICE_ID" -derivedDataPath ./build build
  APP_PATH=$(find ./build/Build/Products -name "*.app" | head -n 1)
  BUNDLE_ID="com.antigravity.CoffeeJournal"

  if [ -z "$APP_PATH" ] && [ -f "./build/Build/Products/Debug-iphonesimulator/CoffeeJournalApp" ]; then
    APP_DIR="./build/Build/Products/Debug-iphonesimulator/CoffeeJournal.app"
    mkdir -p "$APP_DIR"
    cp "./build/Build/Products/Debug-iphonesimulator/CoffeeJournalApp" "$APP_DIR/CoffeeJournal"
    cat <<'EOF' > "$APP_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CoffeeJournal</string>
    <key>CFBundleIdentifier</key>
    <string>com.antigravity.CoffeeJournal</string>
    <key>CFBundleName</key>
    <string>CoffeeJournal</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>17.0</string>
</dict>
</plist>
EOF
    APP_PATH="$APP_DIR"
  fi
fi

# 5. Install & Launch
echo "📦 Installing and launching CoffeeJournal..."
if [ -n "$APP_PATH" ] && [ -d "$APP_PATH" ]; then
  xcrun simctl install "$DEVICE_ID" "$APP_PATH"
  xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
  echo "✅ Successfully launched CoffeeJournal on simulator ($DEVICE_ID)!"
else
  echo "⚠️ App bundle not found at $APP_PATH. Built target scheme successfully."
fi

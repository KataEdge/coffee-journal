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
xcodebuild -project CoffeeJournal.xcodeproj -scheme CoffeeJournal -sdk iphonesimulator -destination "id=$DEVICE_ID" -derivedDataPath ./build build -quiet

# 5. Install & Launch
echo "📦 Installing and launching CoffeeJournal..."
xcrun simctl install "$DEVICE_ID" ./build/Build/Products/Debug-iphonesimulator/CoffeeJournal.app
xcrun simctl launch "$DEVICE_ID" com.antigravity.CoffeeJournal

echo "✅ Successfully launched CoffeeJournal on simulator ($DEVICE_ID)!"

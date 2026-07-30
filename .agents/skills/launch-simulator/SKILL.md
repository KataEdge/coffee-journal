---
name: launch-simulator
description: Builds and launches the latest CoffeeJournal iOS application on the iOS Simulator with multi-agent conflict avoidance.
---

# Launch Simulator Skill

This skill provides procedures and automated scripts to quickly build and launch the CoffeeJournal iOS application in the iOS Simulator.

## Multi-Agent Conflict Avoidance
When multiple AI agents work in parallel across different Git Worktrees:
- The script automatically detects already booted simulator instances (`Booted`) and avoids reusing them.
- It selects an available unbooted (`Shutdown`) iPhone simulator device (e.g., iPhone 17 Pro Max, iPhone 17, iPhone Air).
- The chosen device ID is persisted in `.simulator_id` inside the Worktree directory to ensure consistent reuse on subsequent script executions.
- `Simulator.app` naturally displays multiple booted simulator windows side-by-side on screen.

## Automated Execution (Recommended)
Run the automated launch script:
```bash
./scripts/launch-simulator.sh
```

Optionally pass a target device name or UUID to override auto-selection:
```bash
./scripts/launch-simulator.sh "iPhone 17 Pro Max"
```

This script will:
1. Fetch latest changes from `origin/main`.
2. Reuse `.simulator_id` if present, or find an unbooted iPhone simulator.
3. Save the assigned device ID to `.simulator_id`.
4. Bring `Simulator.app` to the foreground (`open -a Simulator`).
5. Build `CoffeeJournal.xcodeproj` using `xcodebuild`.
6. Install and launch `com.antigravity.CoffeeJournal` on the selected simulator.

## Manual Execution Steps
If running steps manually:
1. **Fetch latest main**:
   ```bash
   git fetch origin main
   ```
2. **Select Unbooted Simulator ID**:
   ```bash
   DEVICE_ID=$(xcrun simctl list devices available | grep -E "iPhone" | grep "Shutdown" | head -n 1 | sed -E 's/.*\(([0-9A-F-]+)\).*/\1/')
   xcrun simctl boot "$DEVICE_ID"
   open -a Simulator
   ```
3. **Build App**:
   ```bash
   xcodebuild -project CoffeeJournal.xcodeproj -scheme CoffeeJournal -sdk iphonesimulator -destination "id=$DEVICE_ID" -derivedDataPath ./build build
   ```
4. **Install and Launch**:
   ```bash
   xcrun simctl install "$DEVICE_ID" ./build/Build/Products/Debug-iphonesimulator/CoffeeJournal.app
   xcrun simctl launch "$DEVICE_ID" com.antigravity.CoffeeJournal
   ```

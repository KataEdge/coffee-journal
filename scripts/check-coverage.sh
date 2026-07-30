#!/bin/bash
set -e

# CoffeeJournal Business Logic Test Coverage Checker
# Target: ViewModels, Domain, Data layers (excluding Presentation Views & Components)

MIN_COVERAGE=90.0

echo "🧪 Running unit tests with code coverage..."
swift test --enable-code-coverage > /dev/null 2>&1

BIN_PATH=$(swift build --show-bin-path 2>/dev/null)
TEST_BUNDLE=$(find "$BIN_PATH" -name "CoffeeJournalPackageTests.xctest" -o -name "CoffeeJournalPackageTests" | head -n 1)

if [ -d "$TEST_BUNDLE/Contents/MacOS" ]; then
  EXECUTABLE="$TEST_BUNDLE/Contents/MacOS/CoffeeJournalPackageTests"
else
  EXECUTABLE="$TEST_BUNDLE"
fi

PROFDATA=$(find .build -name "default.profdata" | head -n 1)

if [ -z "$PROFDATA" ] || [ ! -f "$PROFDATA" ]; then
  echo "❌ Error: Could not find profdata file."
  exit 1
fi

echo "📊 Analyzing coverage for Business Logic layer (ViewModels, Domain, Data)..."

# Filter files under Presentation/ViewModels, Domain/, Data/
REPORT=$(xcrun llvm-cov report "$EXECUTABLE" -instr-profile="$PROFDATA" 2>/dev/null | grep -E "(Presentation/ViewModels/|Presentation/Map/CoffeeMapViewModel\.swift|Domain/|Data/|Core/)" | grep -v "View_Previews" || true)

if [ -z "$REPORT" ]; then
  echo "❌ Error: No matching coverage report lines found."
  exit 1
fi

TOTAL_LINES=0
COVERED_LINES=0

echo "$REPORT" | while read -r line; do
  # Extract total lines and missed lines or calculate covered
  # Format: Filename Regions Missed Cover Functions Missed Cover Lines Missed Cover
  # We extract line metrics (columns 7, 8, 9)
  # Example: Data/DTOs/TastingNoteDTO.swift 5 2 60.00% 5 2 60.00% 75 2 97.33%
  echo "$line"
done

# Calculate aggregate line coverage using awk
SUMMARY=$(echo "$REPORT" | awk '
{
  # In llvm-cov report output:
  # Column 8: Total Lines, Column 9: Missed Lines, Column 10: Line Coverage %
  total += $8
  missed += $9
}
END {
  covered = total - missed
  if (total > 0) {
    percent = (covered / total) * 100
    printf "%.2f %d %d", percent, covered, total
  } else {
    printf "0.00 0 0"
  }
}')

PERCENT=$(echo "$SUMMARY" | awk '{print $1}')
COVERED=$(echo "$SUMMARY" | awk '{print $2}')
TOTAL=$(echo "$SUMMARY" | awk '{print $3}')

echo ""
echo "--------------------------------------------------------"
echo "📈 Business Logic Coverage Summary:"
echo "   Covered Lines : $COVERED / $TOTAL"
echo "   Coverage Rate : $PERCENT%"
echo "   Required Rate : $MIN_COVERAGE%"
echo "--------------------------------------------------------"

# Compare using bc or awk
IS_PASSED=$(awk -v percent="$PERCENT" -v min="$MIN_COVERAGE" 'BEGIN { if (percent >= min) print "1"; else print "0" }')

if [ "$IS_PASSED" -eq 1 ]; then
  echo "✅ SUCCESS: Business logic test coverage ($PERCENT%) meets the $MIN_COVERAGE% requirement!"
  exit 0
else
  echo "❌ FAILURE: Business logic test coverage ($PERCENT%) is below the $MIN_COVERAGE% requirement."
  exit 1
fi

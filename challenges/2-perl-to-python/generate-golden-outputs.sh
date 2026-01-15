#!/bin/bash

# Generate Golden Output Files for Perl → Python Challenge

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEGACY_APP="$SCRIPT_DIR/legacy-app/log_analyzer.pl"
TEST_INPUT="$SCRIPT_DIR/test-inputs/app.log"
OUTPUT_DIR="$SCRIPT_DIR/expected-outputs"

mkdir -p "$OUTPUT_DIR"

echo "Generating golden output files from legacy Perl script..."
echo

# Make Perl script executable
chmod +x "$LEGACY_APP"

# 1. Error summary
echo "✓ Generating: errors.txt"
perl "$LEGACY_APP" "$TEST_INPUT" --errors > "$OUTPUT_DIR/errors.txt"

# 2. Warning summary
echo "✓ Generating: warnings.txt"
perl "$LEGACY_APP" "$TEST_INPUT" --warnings > "$OUTPUT_DIR/warnings.txt"

# 3. Statistics
echo "✓ Generating: stats.txt"
perl "$LEGACY_APP" "$TEST_INPUT" --stats > "$OUTPUT_DIR/stats.txt"

# 4. IP analysis
echo "✓ Generating: ips.txt"
perl "$LEGACY_APP" "$TEST_INPUT" --ips > "$OUTPUT_DIR/ips.txt"

# 5. User login summary
echo "✓ Generating: users.txt"
perl "$LEGACY_APP" "$TEST_INPUT" --users > "$OUTPUT_DIR/users.txt"

# 6. Request timing analysis
echo "✓ Generating: times.txt"
perl "$LEGACY_APP" "$TEST_INPUT" --times > "$OUTPUT_DIR/times.txt"

# 7. JSON outputs
echo "✓ Generating: errors.json"
perl "$LEGACY_APP" "$TEST_INPUT" --errors --json > "$OUTPUT_DIR/errors.json"

echo "✓ Generating: warnings.json"
perl "$LEGACY_APP" "$TEST_INPUT" --warnings --json > "$OUTPUT_DIR/warnings.json"

echo "✓ Generating: stats.json"
perl "$LEGACY_APP" "$TEST_INPUT" --stats --json > "$OUTPUT_DIR/stats.json"

echo "✓ Generating: ips.json"
perl "$LEGACY_APP" "$TEST_INPUT" --ips --json > "$OUTPUT_DIR/ips.json"

echo "✓ Generating: users.json"
perl "$LEGACY_APP" "$TEST_INPUT" --users --json > "$OUTPUT_DIR/users.json"

echo "✓ Generating: times.json"
perl "$LEGACY_APP" "$TEST_INPUT" --times --json > "$OUTPUT_DIR/times.json"

echo
echo "✅ All golden output files generated successfully!"
echo "   Location: $OUTPUT_DIR"
echo
echo "These files represent the expected behavior of the legacy Perl script."
echo "Modernized Python scripts must produce identical outputs."

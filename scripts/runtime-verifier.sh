#!/bin/bash
#
# Runtime Verification Orchestrator
# Runs runtime tests for any challenge using its runtime-spec.yaml
#
# Usage: ./runtime-verifier.sh <challenge-dir> <output-dir> [report-file]
#

set -e

CHALLENGE_DIR="$1"
OUTPUT_DIR="$2"
REPORT_FILE="${3:-runtime-results.json}"

if [[ -z "$CHALLENGE_DIR" || -z "$OUTPUT_DIR" ]]; then
    echo "Usage: $0 <challenge-dir> <output-dir> [report-file]"
    exit 1
fi

RUNTIME_SPEC="$CHALLENGE_DIR/runtime-spec.yaml"

if [[ ! -f "$RUNTIME_SPEC" ]]; then
    echo "⚠ No runtime-spec.yaml found in $CHALLENGE_DIR"
    echo "  Skipping runtime verification"
    exit 0
fi

echo "========================================"
echo "  Runtime Verification"
echo "========================================"
echo ""
echo "Challenge: $CHALLENGE_DIR"
echo "Output: $OUTPUT_DIR"
echo "Spec: $RUNTIME_SPEC"
echo ""

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 is required for runtime verification"
    exit 1
fi

# Check if runtime-orchestrator.py exists
ORCHESTRATOR="$(dirname "$0")/runtime-orchestrator.py"
if [[ ! -f "$ORCHESTRATOR" ]]; then
    echo "ERROR: runtime-orchestrator.py not found at $ORCHESTRATOR"
    exit 1
fi

# Run the orchestrator
python3 "$ORCHESTRATOR" \
    --spec "$RUNTIME_SPEC" \
    --output "$OUTPUT_DIR" \
    --report "$REPORT_FILE" \
    --challenge-dir "$CHALLENGE_DIR"

exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    echo ""
    echo "✓ Runtime verification PASSED"
else
    echo ""
    echo "✗ Runtime verification FAILED"
fi

exit $exit_code

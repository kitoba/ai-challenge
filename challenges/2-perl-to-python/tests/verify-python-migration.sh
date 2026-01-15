#!/bin/bash
#
# Objective Verification: Perl → Python Migration
# Tests that candidate actually modernized (not just faked it)
#
# Usage: ./verify-python-migration.sh <path-to-candidate-output>
#

set -e

OUTPUT_DIR="${1:-.}"
ERRORS=0

echo "========================================"
echo "  Perl → Python Migration Validator"
echo "========================================"
echo ""
echo "Testing: $OUTPUT_DIR"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++)) || true
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo "=== PHASE 1: Perl Artifacts Must Be GONE ==="
echo ""

# Test 1: No .pl files
if find "$OUTPUT_DIR" -name "*.pl" 2>/dev/null | grep -q "\.pl"; then
    fail "Found .pl files (Perl script should be converted)"
    find "$OUTPUT_DIR" -name "*.pl"
else
    pass "No .pl files found"
fi

# Test 2: No Perl shebang
if grep -r "^#!/usr/bin/perl\|^#!/usr/bin/env perl" "$OUTPUT_DIR" 2>/dev/null | grep -q "perl"; then
    fail "Found Perl shebang (#!/usr/bin/perl)"
    grep -r "#!/usr/bin/perl" "$OUTPUT_DIR" | head -3
else
    pass "No Perl shebang found"
fi

# Test 3: No Perl variable syntax (my $var)
if grep -r "my \$\|our \$\|local \$" "$OUTPUT_DIR" 2>/dev/null | grep -v "//.*my \$" | grep -q "my \$"; then
    fail "Found Perl variable declarations (my \$var)"
    grep -r "my \$" "$OUTPUT_DIR" | head -3
else
    pass "No Perl variable declarations found"
fi

# Test 4: No Perl regex binding operator (=~)
if grep -r " =~ " "$OUTPUT_DIR" 2>/dev/null | grep -v "#.*=~" | grep -q "=~"; then
    fail "Found Perl regex binding operator (=~)"
    grep -r " =~ " "$OUTPUT_DIR" | head -3
else
    pass "No Perl regex binding operator found"
fi

# Test 5: No Perl hash/array syntax (%hash, @array)
if grep -rE '\$[a-zA-Z_][a-zA-Z0-9_]*\{|\@[a-zA-Z_]|\%[a-zA-Z_]' "$OUTPUT_DIR" 2>/dev/null | grep -v "#.*[\$@%]" | grep -q "[\$@%]"; then
    warn "Found Perl-style sigils (\$, @, %) - verify these are not Perl remnants"
fi

# Test 6: No Perl postfix conditionals
if grep -rE ' if \$| unless \$| for \$| foreach \$' "$OUTPUT_DIR" 2>/dev/null | grep -v "#" | grep -q "if \$\|unless \$"; then
    warn "Found potential Perl postfix conditionals - verify syntax"
fi

# Test 7: No Perl-specific functions
if grep -r "chomp\|qw(\|scalar\|shift\|push @\|pop @\|keys %\|values %" "$OUTPUT_DIR" 2>/dev/null | grep -v "#.*chomp" | grep -q "chomp\|qw\|scalar"; then
    fail "Found Perl-specific functions (chomp, qw, scalar, etc.)"
    grep -r "chomp\|qw(\|scalar" "$OUTPUT_DIR" | head -3
else
    pass "No Perl-specific functions found"
fi

# Test 8: No Perl-style filehandles
if grep -r "open(.*,.*<\|LOGFILE\|STDOUT\|STDERR" "$OUTPUT_DIR" 2>/dev/null | grep -v "#.*open" | grep -v "sys\." | grep -q "open("; then
    warn "Found potential Perl-style filehandles - verify conversion to Python"
fi

echo ""
echo "=== PHASE 2: Python Artifacts Must EXIST ==="
echo ""

# Test 9: Python file exists
if find "$OUTPUT_DIR" -name "*.py" 2>/dev/null | grep -q "\.py"; then
    pass "Found .py files"
else
    fail "No .py files found"
fi

# Test 10: Python shebang
if grep -r "^#!/usr/bin/env python\|^#!/usr/bin/python" "$OUTPUT_DIR" 2>/dev/null | grep -q "python"; then
    pass "Found Python shebang"
else
    warn "No Python shebang found (acceptable if not needed)"
fi

# Test 11: Python imports exist
if grep -r "^import \|^from .* import" "$OUTPUT_DIR" 2>/dev/null | grep -q "import"; then
    pass "Found Python import statements"
else
    fail "No Python import statements found"
fi

# Test 12: Python standard library usage (re, json, datetime, argparse)
if grep -r "import re\|from re import\|import json\|import datetime\|import argparse" "$OUTPUT_DIR" 2>/dev/null | grep -q "import"; then
    pass "Found Python standard library imports (re, json, datetime, argparse)"
else
    warn "No standard library imports found - check implementation quality"
fi

# Test 13: Python with statement (context managers)
if grep -r "with open(" "$OUTPUT_DIR" 2>/dev/null | grep -q "with open"; then
    pass "Found Python 'with' statement for file handling"
else
    warn "No 'with open()' found - should use context managers for files"
fi

# Test 14: Python dictionary methods
if grep -r "\.get(\|\.items(\|\.keys(\|\.values(" "$OUTPUT_DIR" 2>/dev/null | grep -q "\.get("; then
    pass "Found Python dictionary methods (.get, .items, .keys, .values)"
else
    warn "No Python dict methods found"
fi

# Test 15: Python list comprehensions or generator expressions
if grep -rE '\[.*for .* in .*\]|\(.*for .* in .*\)' "$OUTPUT_DIR" 2>/dev/null | grep -q "for .* in"; then
    pass "Found Python list comprehensions or generator expressions"
else
    warn "No list comprehensions found (recommended Python idiom)"
fi

# Test 16: Python f-strings or .format() (modern string formatting)
if grep -rE 'f["\047]|\.format\(' "$OUTPUT_DIR" 2>/dev/null | grep -q "f[\"']\|\.format"; then
    pass "Found modern Python string formatting (f-strings or .format())"
else
    warn "No f-strings or .format() found - check string formatting approach"
fi

# Test 17: Python class or dataclass
if grep -r "^class \|@dataclass" "$OUTPUT_DIR" 2>/dev/null | grep -q "class "; then
    pass "Found Python class definitions"
else
    warn "No class definitions found (acceptable for simple scripts)"
fi

# Test 18: Python if __name__ == '__main__'
if grep -r "if __name__ == ['\"]__main__['\"]" "$OUTPUT_DIR" 2>/dev/null | grep -q "__name__"; then
    pass "Found if __name__ == '__main__' pattern"
else
    warn "No __name__ == '__main__' guard found"
fi

echo ""
echo "=== PHASE 3: Code Quality & Best Practices ==="
echo ""

# Test 19: argparse for command-line parsing
if grep -r "import argparse\|from argparse import" "$OUTPUT_DIR" 2>/dev/null | grep -q "argparse"; then
    pass "Uses argparse for command-line argument parsing"
else
    warn "Not using argparse (should replace Perl's manual ARGV parsing)"
fi

# Test 20: No global variables (should use functions/classes)
if grep -rE '^[a-zA-Z_][a-zA-Z0-9_]* = ' "$OUTPUT_DIR" 2>/dev/null | grep -v "def \|class " | head -5 | wc -l | grep -q "[3-9]\|[1-9][0-9]"; then
    warn "Found potential global variables - verify proper scoping"
fi

# Test 21: Type hints exist (Python 3.5+)
if grep -rE 'def .*\(.*:.*\) ->|: (str|int|float|dict|list|Dict|List)' "$OUTPUT_DIR" 2>/dev/null | grep -q ":"; then
    pass "Found type hints (modern Python best practice)"
else
    warn "No type hints found (recommended for code quality)"
fi

# Test 22: Exception handling
if grep -r "try:\|except \|except:" "$OUTPUT_DIR" 2>/dev/null | grep -q "try:"; then
    pass "Found exception handling (try/except)"
else
    warn "No exception handling found - verify error handling approach"
fi

echo ""
echo "=== PHASE 4: Output Determinism Requirements ==="
echo ""

# Test 23: JSON output uses sort_keys=True
if grep -r "json\.dumps.*sort_keys=True" "$OUTPUT_DIR" 2>/dev/null | grep -q "sort_keys=True"; then
    pass "Found json.dumps with sort_keys=True (deterministic output)"
else
    warn "No sort_keys=True found - verify JSON output is deterministic"
fi

# Test 24: Dictionary/key sorting for text output
if grep -r "sorted(" "$OUTPUT_DIR" 2>/dev/null | grep -q "sorted("; then
    pass "Found sorted() usage (likely for deterministic ordering)"
else
    warn "No sorted() usage found - verify text output has deterministic key ordering"
fi

echo ""
echo "=== PHASE 5: Functional Equivalence Test ==="
echo ""

# Test 25: Script is executable or has main function
PYTHON_FILE=$(find "$OUTPUT_DIR" -name "*.py" -type f | head -1)
if [ -n "$PYTHON_FILE" ]; then
    if grep -q "if __name__ == ['\"]__main__['\"]" "$PYTHON_FILE" || head -1 "$PYTHON_FILE" | grep -q "#!/usr/bin/env python"; then
        pass "Script appears executable"
    else
        warn "Script might not be directly executable - verify entry point"
    fi
fi

# Test 26: Check if script accepts expected arguments
if [ -n "$PYTHON_FILE" ]; then
    echo "Attempting to run: python $PYTHON_FILE --help"
    if python3 "$PYTHON_FILE" --help 2>/dev/null | grep -q "usage:\|Usage:"; then
        pass "Script provides help text (--help works)"
    else
        warn "No help text found - verify argument handling"
    fi
fi

echo ""
echo "=== PHASE 6: Hidden Test Cases (Robustness Validation) ==="
echo ""

# Check if hidden test directory exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HIDDEN_INPUT_DIR="$SCRIPT_DIR/../test-inputs/HIDDEN"
HIDDEN_OUTPUT_DIR="$SCRIPT_DIR/../expected-outputs-HIDDEN"

if [ -d "$HIDDEN_INPUT_DIR" ] || [ -d "$HIDDEN_OUTPUT_DIR" ]; then
    echo "Note: Hidden test cases available (not shown during development)"
    HIDDEN_COUNT=0

    # Count hidden input files
    if [ -d "$HIDDEN_INPUT_DIR" ]; then
        HIDDEN_COUNT=$(find "$HIDDEN_INPUT_DIR" -name "*.log" 2>/dev/null | wc -l)
    fi

    if [ $HIDDEN_COUNT -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC} $HIDDEN_COUNT hidden test case(s) will be tested (runtime verification required)"
        echo "  Note: Hidden tests include:"
        echo "    - Empty log files (edge case)"
        echo "    - Large log files (performance)"
        echo "    - Malformed log lines (error handling)"
        echo "    - Output determinism (run twice, must match)"
        echo "  These will be fully tested during final evaluation"
    else
        pass "No hidden test cases to verify"
    fi
else
    echo "Note: No hidden test cases directory found (development mode)"
fi

echo ""
echo "========================================"
echo "  Results"
echo "========================================"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ ALL STATIC TESTS PASSED${NC}"
    echo ""
    echo "This appears to be a proper Perl → Python migration!"
    echo ""
    echo "Next: Runtime verification will test:"
    echo "  - Script executes correctly on test data"
    echo "  - Hidden test cases (edge cases, performance)"
    echo "  - Output determinism"
    exit 0
else
    echo -e "${RED}✗ $ERRORS TEST(S) FAILED${NC}"
    echo ""
    echo "This does NOT appear to be a proper migration."
    echo "Review the failures above."
    exit 1
fi

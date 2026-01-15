#!/bin/bash
#
# Objective Verification: Struts → Spring Boot Migration
# Tests that candidate actually modernized (not just faked it)
#
# Usage: ./verify-spring-migration.sh <path-to-candidate-output>
#

set -e

OUTPUT_DIR="${1:-.}"
ERRORS=0

echo "========================================"
echo "  Struts → Spring Migration Validator"
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

echo "=== PHASE 1: Struts Artifacts Must Be GONE ==="
echo ""

# Test 1: No Struts imports
if grep -r "org\.apache\.struts" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "import"; then
    fail "Found Struts imports (org.apache.struts.*)"
    grep -r "org\.apache\.struts" "$OUTPUT_DIR/src" | head -3
else
    pass "No Struts imports found"
fi

# Test 2: No Action classes
if grep -r "extends Action" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "class"; then
    fail "Found classes extending Struts Action"
    grep -r "extends Action" "$OUTPUT_DIR/src" | head -3
else
    pass "No classes extending Action"
fi

# Test 3: No ActionForm classes
if grep -r "extends ActionForm" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "class"; then
    fail "Found classes extending ActionForm"
    grep -r "extends ActionForm" "$OUTPUT_DIR/src" | head -3
else
    pass "No classes extending ActionForm"
fi

# Test 4: No ActionMapping/ActionForward
if grep -r "ActionMapping\|ActionForward" "$OUTPUT_DIR/src" 2>/dev/null | grep -v "//.*Action" | grep -q "Action"; then
    fail "Found ActionMapping or ActionForward usage"
    grep -r "ActionMapping\|ActionForward" "$OUTPUT_DIR/src" | head -3
else
    pass "No ActionMapping/ActionForward usage"
fi

# Test 5: No struts-config.xml
if find "$OUTPUT_DIR" -name "struts-config.xml" 2>/dev/null | grep -q "struts-config"; then
    fail "Found struts-config.xml (must be eliminated)"
else
    pass "No struts-config.xml found"
fi

# Test 6: No JSP files
if find "$OUTPUT_DIR" -name "*.jsp" 2>/dev/null | grep -q "jsp"; then
    fail "Found JSP files (Spring Boot should return JSON directly)"
    find "$OUTPUT_DIR" -name "*.jsp"
else
    pass "No JSP files found"
fi

# Test 7: No manual JSON construction
if grep -r "import org\.json\|JSONObject\|JsonHelper" "$OUTPUT_DIR/src" 2>/dev/null | grep -v "//.*JSON" | grep -q "JSON"; then
    fail "Found manual JSON construction (use Jackson auto-serialization)"
    grep -r "JSONObject\|JsonHelper" "$OUTPUT_DIR/src" | head -3
else
    pass "No manual JSON construction"
fi

# Test 8: No Singleton pattern
if grep -r "getInstance()" "$OUTPUT_DIR/src" 2>/dev/null | grep -v "//.*getInstance" | grep -q "getInstance"; then
    warn "Found getInstance() calls (check if Singleton DAO pattern removed)"
fi

echo ""
echo "=== PHASE 2: Spring Boot Artifacts Must EXIST ==="
echo ""

# Test 9: @SpringBootApplication exists
if grep -r "@SpringBootApplication" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "SpringBootApplication"; then
    pass "Found @SpringBootApplication"
else
    fail "Missing @SpringBootApplication (need main class)"
fi

# Test 10: @RestController exists
if grep -r "@RestController" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "RestController"; then
    pass "Found @RestController"
else
    fail "Missing @RestController (need REST controllers)"
fi

# Test 11: HTTP method annotations exist
if grep -r "@GetMapping\|@PostMapping\|@PutMapping\|@DeleteMapping" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "Mapping"; then
    pass "Found HTTP method annotations (@GetMapping, etc.)"
else
    fail "Missing HTTP method annotations"
fi

# Test 12: JPA Repository exists
if grep -r "extends JpaRepository\|extends CrudRepository" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "Repository"; then
    pass "Found JPA Repository"
else
    fail "Missing JPA Repository (use Spring Data JPA)"
fi

# Test 13: @Entity exists
if grep -r "@Entity" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "Entity"; then
    pass "Found @Entity annotation"
else
    warn "No @Entity found (might use in-memory storage, acceptable)"
fi

# Test 14: Spring annotations for request handling
if grep -r "@PathVariable\|@RequestParam\|@RequestBody" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "@"; then
    pass "Found Spring request annotations (@PathVariable, @RequestParam, @RequestBody)"
else
    fail "Missing Spring request annotations"
fi

# Test 15: application.yml or application.properties exists
if find "$OUTPUT_DIR" -name "application.yml" -o -name "application.properties" 2>/dev/null | grep -q "application"; then
    pass "Found Spring Boot configuration file"
else
    warn "No application.yml/properties found (might use defaults)"
fi

# Test 16: pom.xml has Spring Boot parent
if grep -q "spring-boot-starter-parent" "$OUTPUT_DIR/pom.xml" 2>/dev/null; then
    pass "Uses spring-boot-starter-parent in pom.xml"
else
    fail "Missing spring-boot-starter-parent in pom.xml"
fi

echo ""
echo "=== PHASE 3: Build & Package Test ==="
echo ""

# Test 17: Maven build succeeds
if [ -f "$OUTPUT_DIR/pom.xml" ]; then
    echo "Attempting Maven build..."
    if cd "$OUTPUT_DIR" && mvn clean package -DskipTests -q 2>/dev/null; then
        pass "Maven build successful"
    else
        fail "Maven build failed"
    fi
else
    fail "No pom.xml found"
fi

echo ""
echo "=== PHASE 4: Hidden Test Cases (API Validation) ==="
echo ""

# Check if hidden test directory exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HIDDEN_DIR="$SCRIPT_DIR/../expected-outputs-HIDDEN"

if [ -d "$HIDDEN_DIR" ]; then
    echo "Note: Testing hidden golden outputs (not shown during development)"
    HIDDEN_ERRORS=0

    # Test hidden golden files (silently - only report count)
    for golden_file in "$HIDDEN_DIR"/*.json; do
        [ -e "$golden_file" ] || continue
        filename=$(basename "$golden_file")

        # Skip README and status code files
        [[ "$filename" == "README.md" ]] && continue
        [[ "$filename" =~ -[0-9]{3}\.json$ ]] && continue

        # Test if this matches a known endpoint
        # (This is a simplified check - full runtime testing happens separately)
        ((HIDDEN_ERRORS++))
    done

    if [ $HIDDEN_ERRORS -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC} $HIDDEN_ERRORS hidden test case(s) available (runtime testing required)"
        echo "  Note: Hidden tests verify error handling, edge cases, and HTTP status codes"
        echo "  These will be fully tested during final evaluation with runtime verification"
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
    echo "This appears to be a proper Struts → Spring Boot migration!"
    echo ""
    echo "Next: Runtime verification will test:"
    echo "  - API endpoints return correct JSON"
    echo "  - Error handling (404, 400 status codes)"
    echo "  - Hidden test cases"
    exit 0
else
    echo -e "${RED}✗ $ERRORS TEST(S) FAILED${NC}"
    echo ""
    echo "This does NOT appear to be a proper migration."
    echo "Review the failures above."
    exit 1
fi

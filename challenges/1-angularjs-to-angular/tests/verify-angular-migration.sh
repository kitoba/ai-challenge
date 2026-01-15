#!/bin/bash
#
# Objective Verification: AngularJS → Angular Migration
# Tests that candidate actually modernized (not just faked it)
#
# Usage: ./verify-angular-migration.sh <path-to-candidate-output>
#

set -e

OUTPUT_DIR="${1:-.}"
ERRORS=0

echo "========================================"
echo "  AngularJS → Angular Migration Validator"
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

echo "=== PHASE 1: AngularJS Artifacts Must Be GONE ==="
echo ""

# Test 1: No AngularJS script tag
if grep -r "angular\.js\|angularjs" "$OUTPUT_DIR" 2>/dev/null | grep -qi "script"; then
    fail "Found AngularJS script tag (angular.js)"
    grep -r "angular\.js\|angularjs" "$OUTPUT_DIR" | grep -i "script" | head -3
else
    pass "No AngularJS script tag found"
fi

# Test 2: No ng-app directive
if grep -r "ng-app" "$OUTPUT_DIR" 2>/dev/null | grep -v "//.*ng-app" | grep -q "ng-app"; then
    fail "Found ng-app directive (AngularJS syntax)"
    grep -r "ng-app" "$OUTPUT_DIR" | head -3
else
    pass "No ng-app directive found"
fi

# Test 3: No ng-controller directive
if grep -r "ng-controller" "$OUTPUT_DIR" 2>/dev/null | grep -v "//.*ng-controller" | grep -q "ng-controller"; then
    fail "Found ng-controller directive (AngularJS syntax)"
    grep -r "ng-controller" "$OUTPUT_DIR" | head -3
else
    pass "No ng-controller directive found"
fi

# Test 4: No $scope usage
if grep -r "\$scope" "$OUTPUT_DIR/src" 2>/dev/null | grep -v "//.*\$scope" | grep -q "\$scope"; then
    fail "Found \$scope usage (AngularJS pattern)"
    grep -r "\$scope" "$OUTPUT_DIR/src" | head -3
else
    pass "No \$scope usage found"
fi

# Test 5: No angular.module() calls
if grep -r "angular\.module" "$OUTPUT_DIR" 2>/dev/null | grep -v "//.*angular\.module" | grep -q "angular\.module"; then
    fail "Found angular.module() calls (AngularJS syntax)"
    grep -r "angular\.module" "$OUTPUT_DIR" | head -3
else
    pass "No angular.module() calls found"
fi

# Test 6: No .controller() or .service() registrations
if grep -r "\.controller(\|\.service(\|\.factory(\|\.directive(" "$OUTPUT_DIR" 2>/dev/null | grep -v "//.*\." | grep -q "\."; then
    fail "Found AngularJS module registrations (.controller, .service, etc.)"
    grep -r "\.controller(\|\.service(\|\.factory(" "$OUTPUT_DIR" | head -3
else
    pass "No AngularJS module registrations found"
fi

# Test 7: No window.APP_CONFIG global state
if grep -r "window\.APP_CONFIG\|window\[" "$OUTPUT_DIR/src" 2>/dev/null | grep -v "//.*window" | grep -q "window"; then
    warn "Found window global usage (check if global state pattern removed)"
fi

# Test 8: No callback-based services
if grep -r "successCallback\|errorCallback" "$OUTPUT_DIR/src" 2>/dev/null | grep -v "//.*Callback" | grep -q "Callback"; then
    fail "Found callback-based patterns (should use Observables)"
    grep -r "successCallback\|errorCallback" "$OUTPUT_DIR/src" | head -3
else
    pass "No callback-based patterns found"
fi

echo ""
echo "=== PHASE 2: Angular (Modern) Artifacts Must EXIST ==="
echo ""

# Test 9: @Component decorator exists
if grep -r "@Component" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "@Component"; then
    pass "Found @Component decorator"
else
    fail "Missing @Component decorator (need Angular components)"
fi

# Test 10: @Injectable decorator exists
if grep -r "@Injectable" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "@Injectable"; then
    pass "Found @Injectable decorator"
else
    fail "Missing @Injectable decorator (need Angular services)"
fi

# Test 11: TypeScript files exist
if find "$OUTPUT_DIR/src" -name "*.ts" 2>/dev/null | grep -q "\.ts"; then
    pass "Found TypeScript files (.ts)"
else
    fail "No TypeScript files found (Angular uses TypeScript)"
fi

# Test 12: Angular imports exist
if grep -r "from '@angular/core'\|from '@angular/common'" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "@angular"; then
    pass "Found Angular framework imports"
else
    fail "Missing Angular framework imports"
fi

# Test 13: RxJS Observables exist
if grep -r "Observable\|import.*rxjs" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "Observable\|rxjs"; then
    pass "Found RxJS Observable usage"
else
    fail "Missing RxJS Observables (should replace callbacks)"
fi

# Test 14: Component templates exist
if grep -r "template:\|templateUrl:" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "template"; then
    pass "Found component templates"
else
    fail "Missing component templates"
fi

# Test 15: Angular structural directives (*ngFor, *ngIf)
if grep -r "\*ngFor\|\*ngIf" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "\*ng"; then
    pass "Found Angular structural directives (*ngFor, *ngIf)"
else
    warn "No structural directives found (might use different patterns)"
fi

# Test 16: Angular property binding or event binding
if grep -r "\[.*\]=\|(.*\)=" "$OUTPUT_DIR/src" 2>/dev/null | grep -E "\[|\(" | grep -q "="; then
    pass "Found Angular binding syntax ([property] or (event))"
else
    warn "No Angular binding syntax found"
fi

# Test 17: TypeScript interfaces exist
if grep -r "^export interface\|^interface" "$OUTPUT_DIR/src" 2>/dev/null | grep -q "interface"; then
    pass "Found TypeScript interfaces"
else
    warn "No TypeScript interfaces found (recommended for type safety)"
fi

echo ""
echo "=== PHASE 3: Build System & Dependencies ==="
echo ""

# Test 18: package.json exists
if [ -f "$OUTPUT_DIR/package.json" ]; then
    pass "Found package.json"
else
    fail "Missing package.json"
fi

# Test 19: Angular dependencies in package.json
if [ -f "$OUTPUT_DIR/package.json" ]; then
    if grep -q "@angular/core" "$OUTPUT_DIR/package.json"; then
        pass "package.json has @angular/core dependency"
    else
        fail "package.json missing @angular/core dependency"
    fi
fi

# Test 20: TypeScript configuration exists
if [ -f "$OUTPUT_DIR/tsconfig.json" ] || [ -f "$OUTPUT_DIR/tsconfig.app.json" ]; then
    pass "Found TypeScript configuration"
else
    fail "Missing tsconfig.json"
fi

# Test 21: Angular CLI configuration exists
if [ -f "$OUTPUT_DIR/angular.json" ]; then
    pass "Found angular.json (Angular CLI project)"
else
    warn "No angular.json found (might use different build system)"
fi

echo ""
echo "=== PHASE 4: Build Test ==="
echo ""

# Test 22: npm install succeeds
if [ -f "$OUTPUT_DIR/package.json" ]; then
    echo "Attempting npm install..."
    if cd "$OUTPUT_DIR" && npm install --silent 2>/dev/null; then
        pass "npm install successful"
    else
        fail "npm install failed"
    fi
fi

# Test 23: Build succeeds
if [ -f "$OUTPUT_DIR/package.json" ]; then
    echo "Attempting build..."
    if cd "$OUTPUT_DIR" && npm run build 2>/dev/null; then
        pass "Build successful"
    else
        fail "Build failed"
    fi
fi

echo ""
echo "========================================"
echo "  Results"
echo "========================================"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
    echo ""
    echo "This appears to be a proper AngularJS → Angular migration!"
    exit 0
else
    echo -e "${RED}✗ $ERRORS TEST(S) FAILED${NC}"
    echo ""
    echo "This does NOT appear to be a proper migration."
    echo "Review the failures above."
    exit 1
fi

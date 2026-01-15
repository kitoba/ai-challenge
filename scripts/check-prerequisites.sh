#!/bin/bash

# Check Prerequisites for AI Modernization Challenge
# Validates that all required tools are installed and working

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=================================================="
echo "   AI Modernization Challenge - Prerequisites"
echo "=================================================="
echo ""
echo "Checking your environment..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MISSING=()
WARNINGS=()
SUCCESS=()

# Function to check command
check_command() {
    local cmd=$1
    local name=$2
    local version_cmd=$3
    local required=$4  # "required" or "optional"

    if command -v "$cmd" &> /dev/null; then
        local version=$($version_cmd 2>&1 | head -n1)
        echo -e "${GREEN}✓${NC} $name: $version"
        SUCCESS+=("$name")
    else
        if [ "$required" = "required" ]; then
            echo -e "${RED}✗${NC} $name: NOT FOUND (REQUIRED)"
            MISSING+=("$name")
        else
            echo -e "${YELLOW}⚠${NC} $name: NOT FOUND (optional for some challenges)"
            WARNINGS+=("$name")
        fi
    fi
}

echo "=== Core Tools ==="
check_command "node" "Node.js" "node --version" "required"
check_command "npm" "npm" "npm --version" "required"
check_command "python3" "Python 3" "python3 --version" "required"
check_command "perl" "Perl" "perl --version" "required"
check_command "curl" "curl" "curl --version" "required"
check_command "git" "Git" "git --version" "required"

echo ""
echo "=== Challenge-Specific Tools ==="
check_command "java" "Java" "java -version" "optional"
check_command "mvn" "Maven" "mvn --version" "optional"

echo ""
echo "=== Optional Tools ==="
check_command "jq" "jq (JSON processor)" "jq --version" "optional"

echo ""
echo "=== System Info ==="
echo "OS: $(uname -s)"
echo "Architecture: $(uname -m)"
echo "Shell: $SHELL"

echo ""
echo "=================================================="
echo "   Results Summary"
echo "=================================================="

if [ ${#SUCCESS[@]} -gt 0 ]; then
    echo -e "${GREEN}✓ Working (${#SUCCESS[@]}):${NC}"
    for tool in "${SUCCESS[@]}"; do
        echo "  - $tool"
    done
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠ Optional (${#WARNINGS[@]}):${NC}"
    for tool in "${WARNINGS[@]}"; do
        echo "  - $tool"
    done
    echo ""
    echo "Note: Java/Maven only needed for Challenge 3 (Struts→Spring Boot)"
fi

if [ ${#MISSING[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}✗ Missing Required (${#MISSING[@]}):${NC}"
    for tool in "${MISSING[@]}"; do
        echo "  - $tool"
    done
    echo ""
    echo "=================================================="
    echo "   Installation Options"
    echo "=================================================="
    echo ""
    echo "Option 1: Auto-install (Ubuntu/Debian)"
    echo "  ./scripts/setup-environment.sh"
    echo ""
    echo "Option 2: Manual installation"
    echo "  See: docs/PREREQUISITES.md"
    echo ""
    exit 1
fi

echo ""
echo "=================================================="
echo -e "${GREEN}✓ All required tools are installed!${NC}"
echo "=================================================="
echo ""
echo "Next steps:"
echo "  1. Read: README.md"
echo "  2. Choose a challenge: challenges/1-angularjs-to-angular/"
echo "  3. Build your AI agent!"
echo ""

exit 0

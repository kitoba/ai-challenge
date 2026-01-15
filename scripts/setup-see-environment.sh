#!/bin/bash
#
# Setup Script for Nationwide SEE (Software Engineering Environments)
# Uses nwx (no sudo required)
#
# Usage: ./scripts/setup-see-environment.sh
#

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  AI Modernization Challenge - SEE Setup${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if nwx is available
if ! command -v nwx &> /dev/null; then
    echo -e "${RED}✗ Error: nwx not found${NC}"
    echo ""
    echo "This script is for Nationwide SEE (Software Engineering Environments) only."
    echo ""
    echo "If you're NOT in SEE:"
    echo "  - Use a personal machine? See docs/PREREQUISITES.md"
    echo "  - Need SEE access? Visit https://see.nwie.net/"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ nwx detected - running in SEE environment${NC}"
echo ""

# Check current installation status
echo -e "${BLUE}Checking current tool status...${NC}"
echo ""

# Get status of key tools
nwx app status node python java maven 2>/dev/null || true

echo ""
echo -e "${BLUE}Installing required tools via nwx...${NC}"
echo ""

# List of tools to install
TOOLS_TO_INSTALL=()

# Check if Java is installed
if ! nwx app status java 2>/dev/null | grep -q "✓"; then
    TOOLS_TO_INSTALL+=("java")
    echo "  → Will install: Java 21 LTS"
else
    echo -e "${GREEN}  ✓ Java already installed${NC}"
fi

# Check if Maven is installed
if ! nwx app status maven 2>/dev/null | grep -q "✓"; then
    TOOLS_TO_INSTALL+=("maven")
    echo "  → Will install: Maven 3.9"
else
    echo -e "${GREEN}  ✓ Maven already installed${NC}"
fi

# Check if Node is installed
if ! nwx app status node 2>/dev/null | grep -q "✓"; then
    TOOLS_TO_INSTALL+=("node")
    echo "  → Will install: Node.js (latest LTS)"
else
    echo -e "${GREEN}  ✓ Node.js already installed${NC}"
fi

# Check if Python is installed
if ! nwx app status python 2>/dev/null | grep -q "✓"; then
    TOOLS_TO_INSTALL+=("python")
    echo "  → Will install: Python 3"
else
    echo -e "${GREEN}  ✓ Python already installed${NC}"
fi

echo ""

# Install tools if needed
if [ ${#TOOLS_TO_INSTALL[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All required tools already installed!${NC}"
else
    echo -e "${YELLOW}Installing ${#TOOLS_TO_INSTALL[@]} tool(s): ${TOOLS_TO_INSTALL[*]}${NC}"
    echo ""
    echo "This may take 3-5 minutes..."
    echo ""

    # Install with nwx (will wait for completion)
    nwx app install "${TOOLS_TO_INSTALL[@]}"

    echo ""
    echo -e "${GREEN}✓ Installation complete!${NC}"
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Verification${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Reload environment to pick up new PATH
export PATH="$HOME/.local/bin:$PATH"

# Check versions
echo "Installed versions:"
echo ""

if command -v java &> /dev/null; then
    echo -e "${GREEN}✓ Java:${NC}"
    java -version 2>&1 | head -1
else
    echo -e "${YELLOW}⚠ Java not found in PATH (may need new shell session)${NC}"
fi

if command -v mvn &> /dev/null; then
    echo -e "${GREEN}✓ Maven:${NC}"
    mvn -version 2>&1 | head -1
else
    echo -e "${YELLOW}⚠ Maven not found in PATH (may need new shell session)${NC}"
fi

if command -v node &> /dev/null; then
    echo -e "${GREEN}✓ Node.js:${NC}"
    node -v
else
    echo -e "${YELLOW}⚠ Node.js not found in PATH (may need new shell session)${NC}"
fi

if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✓ Python:${NC}"
    python3 --version
else
    echo -e "${YELLOW}⚠ Python not found in PATH${NC}"
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Next Steps${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo "1. If tools aren't in PATH, start a new terminal session:"
echo "   source ~/.bashrc"
echo ""
echo "2. Verify all prerequisites:"
echo "   ./scripts/check-prerequisites.sh"
echo ""
echo "3. Start the challenges:"
echo "   cat README.md"
echo ""
echo -e "${GREEN}Setup complete! Happy coding!${NC}"
echo ""

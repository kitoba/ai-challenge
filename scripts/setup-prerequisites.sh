#!/bin/bash
#
# One-Step Prerequisites Setup
# Works in both SEE and personal machines
#
# Usage: ./scripts/setup-prerequisites.sh
#

set -e

echo "=================================================="
echo "  AI Modernization Challenge - Prerequisites"
echo "=================================================="
echo ""

# Detect environment
if command -v nwx &> /dev/null; then
    echo "✓ Detected SEE environment (nwx available)"
    echo ""
    echo "Checking tool installation status..."
    echo ""

    # Check which tools need installation
    TOOLS_TO_INSTALL=()

    for tool in node python java maven; do
        if nwx app status "$tool" 2>/dev/null | grep -q "✓"; then
            echo "  ✓ $tool already installed"
        else
            echo "  → Will install: $tool"
            TOOLS_TO_INSTALL+=("$tool")
        fi
    done

    echo ""

    # Only run install if there are tools to install
    if [ ${#TOOLS_TO_INSTALL[@]} -gt 0 ]; then
        echo "Installing ${#TOOLS_TO_INSTALL[@]} tool(s)..."
        nwx app install "${TOOLS_TO_INSTALL[@]}"
        echo ""
        echo "✓ Tool installation complete!"
    else
        echo "✓ All tools already installed!"
    fi

    echo ""
    
elif [ -f /etc/os-release ] && grep -q "ubuntu\|debian" /etc/os-release; then
    echo "⚠ Detected Ubuntu/Debian (not SEE)"
    echo ""
    echo "⚠ WARNING: You are NOT in SEE environment."
    echo "⚠ We recommend using SEE: https://see.nwie.net/"
    echo ""
    echo "If you proceed, you'll need sudo access to install tools."
    echo ""
    read -p "Continue with sudo installation? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled. Please use SEE or see docs/PREREQUISITES.md"
        exit 0
    fi
    
    # Run the Ubuntu setup script
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    "$SCRIPT_DIR/setup-environment.sh"
    
else
    echo "❌ Unsupported environment"
    echo ""
    echo "Please either:"
    echo "  1. Use SEE: https://see.nwie.net/ (recommended)"
    echo "  2. See docs/PREREQUISITES.md for manual installation"
    echo ""
    exit 1
fi

echo ""
echo "=================================================="
echo "  Verifying Installation"
echo "=================================================="
echo ""

# Run verification script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/check-prerequisites.sh"

echo ""
echo "=================================================="
echo "  Next Steps"
echo "=================================================="
echo ""
echo "✓ Prerequisites installed!"
echo ""
echo "Read the challenges:"
echo "  cat README.md"
echo ""
echo "Start with Challenge 1 (easiest):"
echo "  cd challenges/1-angularjs-to-angular"
echo "  cat README.md"
echo ""

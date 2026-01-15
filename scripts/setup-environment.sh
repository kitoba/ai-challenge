#!/bin/bash
#
# Setup Environment for AI Modernization Challenge
# FOR PERSONAL MACHINES ONLY - Ubuntu/Debian with sudo access
#
# ⚠️  WARNING: This script will NOT work in Nationwide SEE!
# ⚠️  SEE doesn't allow sudo access.
#
# If using SEE (recommended): Use ./scripts/setup-see-environment.sh
#

set -e

# Check if running in SEE (nwx exists)
if command -v nwx &> /dev/null; then
    echo "❌ ERROR: This script uses sudo and won't work in SEE."
    echo ""
    echo "Use instead: ./scripts/setup-see-environment.sh"
    echo ""
    exit 1
fi

echo "=================================================="
echo "   AI Modernization Challenge - Environment Setup"
echo "=================================================="
echo ""
echo "This script will install required tools for:"
echo "  - Challenge 1: Node.js 22.x LTS, npm"
echo "  - Challenge 2: Python 3.12+, Perl"
echo "  - Challenge 3: Java 21 LTS, Maven"
echo "  - All: Git, curl, jq"
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ Cannot detect OS. Manual installation required."
    exit 1
fi

# Check if running on Ubuntu/Debian
if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
    echo "⚠️  This script is designed for Ubuntu/Debian."
    echo "Detected OS: $OS"
    echo ""
    echo "For other systems, see docs/PREREQUISITES.md for manual installation."
    exit 1
fi

# Check for sudo
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  Running as root. This is not recommended."
    echo "Please run as a regular user (script will prompt for sudo when needed)."
    exit 1
fi

if ! command -v sudo &> /dev/null; then
    echo "❌ sudo is required but not installed."
    echo "Please contact your system administrator."
    exit 1
fi

echo "Detected: Ubuntu/Debian"
echo ""
echo "The script will now install missing packages."
echo "You may be prompted for your password (sudo)."
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "=================================================="
echo "   Updating package index..."
echo "=================================================="
sudo apt-get update

echo ""
echo "=================================================="
echo "   Installing Core Tools..."
echo "=================================================="

# Git
if ! command -v git &> /dev/null; then
    echo "Installing Git..."
    sudo apt-get install -y git
else
    echo "✓ Git already installed"
fi

# curl
if ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    sudo apt-get install -y curl
else
    echo "✓ curl already installed"
fi

# jq (JSON processor)
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    sudo apt-get install -y jq
else
    echo "✓ jq already installed"
fi

echo ""
echo "=================================================="
echo "   Installing Node.js and npm..."
echo "=================================================="

if ! command -v node &> /dev/null; then
    echo "Installing Node.js 22.x LTS..."

    # Remove old NodeSource setup if exists
    sudo rm -f /etc/apt/sources.list.d/nodesource.list

    # Install Node.js 22.x (Active LTS)
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs

    echo "✓ Node.js installed: $(node --version)"
else
    echo "✓ Node.js already installed: $(node --version)"
fi

if ! command -v npm &> /dev/null; then
    echo "Installing npm..."
    sudo apt-get install -y npm
else
    echo "✓ npm already installed: $(npm --version)"
fi

echo ""
echo "=================================================="
echo "   Installing Python 3..."
echo "=================================================="

if ! command -v python3 &> /dev/null; then
    echo "Installing Python 3..."
    sudo apt-get install -y python3 python3-pip
else
    echo "✓ Python 3 already installed: $(python3 --version)"
fi

echo ""
echo "=================================================="
echo "   Installing Perl..."
echo "=================================================="

if ! command -v perl &> /dev/null; then
    echo "Installing Perl..."
    sudo apt-get install -y perl
else
    echo "✓ Perl already installed: $(perl --version | head -n2 | tail -n1)"
fi

echo ""
echo "=================================================="
echo "   Installing Java and Maven..."
echo "=================================================="

if ! command -v java &> /dev/null; then
    echo "Installing OpenJDK 21 LTS..."
    sudo apt-get install -y openjdk-21-jdk
    echo "✓ Java installed: $(java -version 2>&1 | head -n1)"
else
    echo "✓ Java already installed: $(java -version 2>&1 | head -n1)"
fi

if ! command -v mvn &> /dev/null; then
    echo "Installing Maven..."
    sudo apt-get install -y maven
    echo "✓ Maven installed: $(mvn --version | head -n1)"
else
    echo "✓ Maven already installed: $(mvn --version | head -n1)"
fi

echo ""
echo "=================================================="
echo "   Verifying Installation..."
echo "=================================================="
echo ""

# Run the check script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/check-prerequisites.sh"

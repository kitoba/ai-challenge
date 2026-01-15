#!/bin/bash
#
# Install Java and Maven only (for Challenge 3: Struts→Spring Boot)
# FOR PERSONAL MACHINES ONLY - Ubuntu/Debian with sudo access
#
# ⚠️  WARNING: This script will NOT work in Nationwide SEE!
# ⚠️  SEE doesn't allow sudo access.
#
# If using SEE (recommended): nwx app install java maven
#

set -e

# Check if running in SEE (nwx exists)
if command -v nwx &> /dev/null; then
    echo "❌ ERROR: This script uses sudo and won't work in SEE."
    echo ""
    echo "Use instead: nwx app install java maven"
    echo ""
    exit 1
fi

echo "=================================================="
echo "   Install Java & Maven"
echo "=================================================="
echo ""
echo "This script installs only Java 21 LTS and Maven."
echo "Required for Challenge 3 (Struts→Spring Boot)."
echo ""

# Check if already installed
JAVA_INSTALLED=false
MAVEN_INSTALLED=false

if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n1)
    echo "✓ Java already installed: $JAVA_VERSION"
    JAVA_INSTALLED=true
else
    echo "✗ Java not found - will install OpenJDK 21 LTS"
fi

if command -v mvn &> /dev/null; then
    MAVEN_VERSION=$(mvn --version | head -n1)
    echo "✓ Maven already installed: $MAVEN_VERSION"
    MAVEN_INSTALLED=true
else
    echo "✗ Maven not found - will install"
fi

echo ""

# If both installed, exit
if [ "$JAVA_INSTALLED" = true ] && [ "$MAVEN_INSTALLED" = true ]; then
    echo "✅ Java and Maven already installed - nothing to do!"
    exit 0
fi

# Detect OS
if [ ! -f /etc/os-release ]; then
    echo "❌ Cannot detect OS."
    echo "Please install manually:"
    echo "  - Java: https://adoptium.net/"
    echo "  - Maven: https://maven.apache.org/"
    exit 1
fi

. /etc/os-release
OS=$ID

if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
    echo "⚠️  This script is for Ubuntu/Debian only."
    echo "Detected OS: $OS"
    echo ""
    echo "For other systems:"
    echo "  - macOS: brew install openjdk@17 maven"
    echo "  - Windows: Use Chocolatey or manual download"
    exit 1
fi

# Check for sudo
if ! command -v sudo &> /dev/null; then
    echo "❌ sudo is required."
    exit 1
fi

echo "Ready to install missing tools."
echo "You may be prompted for your password (sudo)."
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "Updating apt package index..."
sudo apt-get update -qq

# Install Java if needed
if [ "$JAVA_INSTALLED" = false ]; then
    echo ""
    echo "Installing OpenJDK 21 LTS..."
    sudo apt-get install -y openjdk-21-jdk

    JAVA_VERSION=$(java -version 2>&1 | head -n1)
    echo "✓ Java installed: $JAVA_VERSION"
fi

# Install Maven if needed
if [ "$MAVEN_INSTALLED" = false ]; then
    echo ""
    echo "Installing Maven..."
    sudo apt-get install -y maven

    MAVEN_VERSION=$(mvn --version | head -n1)
    echo "✓ Maven installed: $MAVEN_VERSION"
fi

echo ""
echo "=================================================="
echo "✅ Installation Complete!"
echo "=================================================="
echo ""

# Show versions
echo "Installed versions:"
java -version 2>&1 | head -n1
mvn --version | head -n1

echo ""
echo "Next steps:"
echo "  1. Test the Struts app:"
echo "     cd challenges/3-struts-to-spring/legacy-app"
echo "     mvn clean package"
echo "     mvn jetty:run"
echo ""
echo "  2. Verify everything:"
echo "     ./scripts/check-prerequisites.sh"
echo ""

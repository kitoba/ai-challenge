# Prerequisites - AI Modernization Challenge

This document lists all tools required to complete the challenges and test your AI agent.

---

## 🎯 Recommended: Use Nationwide SEE (Software Engineering Environments)

**We strongly recommend using Nationwide's standardized Software Engineering Environments (SEE) for this challenge.**

### Why SEE?

- ✅ **Pre-configured** - All tools installed and tested
- ✅ **Standardized** - Same environment we use for evaluation
- ✅ **Cloud-based** - Access from anywhere via browser
- ✅ **Zero setup** - Start coding immediately

### Getting Started with SEE

1. **Access SEE:** [https://see.nwie.net/](https://see.nwie.net/)
2. **Need help?** [SEE Getting Started Guide](https://minerva.nwie.net/catalog/default/component/software-engineering-environments/docs/getting-started)

Once you're in your SEE environment:

```bash
# Install required tools (one-time setup)
nwx app install java maven

# Verify installation
nwx app status node python java maven

# Clone and start
git clone <this-repo-url>
cd ai-modernization-challenge
./scripts/check-prerequisites.sh  # Verify everything is ready
```

**Note:** Node and Python are typically pre-installed in SEE. Java and Maven need to be installed using `nwx`.

---

## ⚠️ Important: Environment Setup is Your Responsibility

**This challenge tests your ability to work independently with minimal guidance.**

- ✅ **SEE environment** - Fully supported, pre-configured, recommended
- ⚠️ **Personal machines** - You're responsible for setup and troubleshooting
- ❌ **No support** - Environment issues on personal machines are at your own risk

**Part of this challenge is demonstrating you're familiar enough with developer tools to configure your own environment if needed.** If you choose not to use SEE, we assume you know what you're doing.

---

## Quick Start

### Option 1: Use SEE (Recommended) ⭐

Access [https://see.nwie.net/](https://see.nwie.net/) and install required tools:

```bash
# Install Java and Maven (Node/Python usually pre-installed)
nwx app install java maven

# Verify
nwx app status node python java maven
./scripts/check-prerequisites.sh
```

**Why nwx?** It's Nationwide's software manager for SEE - no sudo required, installs to your user directory.

### Option 2: Manual Installation (Personal Machines)

**⚠️ You're on your own for personal machine setup.**

See platform-specific instructions below. Remember: **no support for personal machine issues.**

---

## Required Tools

### All Challenges

| Tool | Version | Purpose |
|------|---------|---------|
| **Git** | 2.x+ | Clone repo, version control |
| **curl** | Any | Testing APIs |
| **Python 3** | 3.12+ (3.13 recommended) | Challenge 2 (Perl→Python) |
| **Perl** | 5.30+ | Challenge 2 (run legacy script) |

### Challenge 1: AngularJS → Angular

| Tool | Version | Purpose |
|------|---------|---------|
| **Node.js** | 20.x or 22.x LTS (recommended) | Run Angular apps |
| **npm** | 9.x or 10.x | Install dependencies |

### Challenge 3: Struts → Spring Boot

| Tool | Version | Purpose |
|------|---------|---------|
| **Java** | 17 LTS or 21 LTS (recommended) | Run Spring Boot apps (**17+ required**) |
| **Maven** | 3.8+ (3.9 recommended) | Build Java projects |

### Optional Tools

| Tool | Purpose |
|------|---------|
| **jq** | Pretty-print JSON (helpful for debugging) |
| **Playwright** | UI testing (for validation only, not required) |

---

## Installation Instructions

### SEE Environment (Nationwide Workspaces)

**Use nwx (no sudo required):**
```bash
# Install Java and Maven
nwx app install java maven

# Check available tools
nwx list

# Check installed status
nwx app status java maven node python
```

**Available tools via nwx:**
- `java` (installs Java 21 LTS by default)
- `maven` (installs Maven 3.9)
- `node` (installs Node.js, usually pre-installed)
- `python` (installs Python 3.x, usually pre-installed)

**Documentation:** [nwx Software Guide](https://minerva.apps.nwie.net/catalog/default/component/software-engineering-environments/docs/optional-software)

---

### Ubuntu/Debian (Personal Machines - NOT SEE)

**⚠️ Only if NOT using SEE. Requires sudo access.**

```bash
# Update package index
sudo apt-get update

# Core tools
sudo apt-get install -y git curl jq perl python3 python3-pip

# Node.js 22.x LTS
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Java 21 LTS and Maven
sudo apt-get install -y openjdk-21-jdk maven
```

### macOS

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install git curl jq node python perl openjdk@21 maven
```

### Windows (WSL2 Recommended)

1. **Enable WSL2:**
   - Open PowerShell as Administrator
   - Run: `wsl --install`
   - Restart computer

2. **Install Ubuntu from Microsoft Store**

3. **Follow Ubuntu instructions above**

Alternatively, use native Windows tools:
- Node.js: https://nodejs.org/
- Python: https://www.python.org/downloads/
- Java/Maven: https://adoptium.net/ + https://maven.apache.org/
- Perl: http://strawberryperl.com/

---

## Verification

After installation, verify your environment:

```bash
./scripts/check-prerequisites.sh
```

**Expected output:**
```
✓ Node.js: v22.x.x
✓ npm: 10.x.x
✓ Python 3: Python 3.12.x or 3.13.x
✓ Perl: v5.30+
✓ curl: curl 7.x.x or 8.x.x
✓ Git: git version 2.x.x
✓ Java: openjdk version "21.x.x"
✓ Maven: Apache Maven 3.9.x
✓ jq: jq-1.6

✓ All required tools are installed!
```

---

## Testing Individual Challenges

### Challenge 1: AngularJS → Angular

```bash
cd challenges/1-angularjs-to-angular/legacy-app
npm install
npm run serve
# Open http://localhost:8080
```

**Requirements:** Node.js, npm

### Challenge 2: Perl → Python

```bash
cd challenges/2-perl-to-python
perl legacy-app/log_analyzer.pl test-inputs/app.log --stats
```

**Requirements:** Perl, Python 3

### Challenge 3: Struts → Spring Boot

```bash
cd challenges/3-struts-to-spring/legacy-app
mvn clean package
mvn jetty:run
# Open http://localhost:8080/products
```

**Requirements:** Java 17+ (21 LTS recommended), Maven

---

## Troubleshooting

### "command not found" errors

Run the setup script:
```bash
./scripts/setup-environment.sh
```

### Node.js version conflicts

Use `nvm` (Node Version Manager):
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install Node.js 22
nvm install 22
nvm use 22
```

### Java version conflicts

Ubuntu/Debian:
```bash
# List installed versions
update-java-alternatives --list

# Switch to Java 21
sudo update-java-alternatives --set /path/to/java-21-openjdk-amd64
```

macOS:
```bash
# Use jenv
brew install jenv
jenv add /Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home
jenv global 21
```

### Maven not found after Java install

Ensure Maven is installed and JAVA_HOME is set:
```bash
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH
```

### Permission denied errors

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

---

## SEE / Nationwide Workspaces

If you're using Nationwide SEE (Software Engineering Environments):

1. **Pre-installed:** Git, curl, Python 3, Perl, Node.js (usually)
2. **Install via nwx:** Java, Maven
3. **Command:** `nwx app install java maven`

**No sudo access in SEE** - use `nwx` instead of `apt-get` or manual installation scripts.

---

## Minimum System Requirements

- **OS:** Ubuntu 20.04+, macOS 12+, Windows 10+ (with WSL2)
- **RAM:** 4GB minimum, 8GB recommended
- **Disk:** 10GB free space
- **CPU:** Any modern CPU (2+ cores recommended)

---

## Support Policy

**Environment setup is your responsibility.** This challenge tests your ability to work independently with standard developer tools.

### If You Need Help

1. **Use SEE (Recommended):** [https://see.nwie.net/](https://see.nwie.net/) - pre-configured, tested, supported
2. **Troubleshoot yourself:** Check this document, run `./scripts/check-prerequisites.sh`, review logs
3. **No personal support:** We don't provide help configuring personal machines

### When to Contact Us

- **SEE access issues:** Contact your IT support
- **Actual bugs in challenge code:** Create an issue in the repo
- **Environment questions:** Not supported—this is self-service

**Remember:** If you can't configure Node.js, Java, and Maven independently, this role may not be a good fit.

---

## Quick Reference: Tool Versions

**Tested and confirmed working:**

| Tool | Version | Status |
|------|---------|--------|
| Node.js | 22.x LTS | ✅ Recommended (Active LTS) |
| Node.js | 20.x LTS | ✅ Works (Maintenance LTS) |
| npm | 10.x | ✅ Recommended |
| npm | 9.x | ✅ Works |
| Python | 3.13 | ✅ Recommended (Latest) |
| Python | 3.12 | ✅ Works |
| Perl | 5.34+ | ✅ Recommended |
| Perl | 5.30+ | ✅ Works |
| Java | 21 LTS | ✅ Recommended |
| Java | 17 LTS | ✅ Works (Minimum for Spring Boot 3.x) |
| Maven | 3.9 | ✅ Recommended |
| Maven | 3.8 | ✅ Works |

---

## Nationwide SEE Environment

**The challenges have been developed and tested in Nationwide's SEE environment**, which runs Ubuntu Linux with all required tools pre-installed. Using SEE ensures you have the exact same environment we use for evaluation.

**All scripts in this repo are tested and confirmed working in SEE.**

---

**Last Updated:** 2025-10-16

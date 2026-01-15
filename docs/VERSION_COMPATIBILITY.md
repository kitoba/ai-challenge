# Version Compatibility Matrix

**Last Updated:** 2025-10-16

This document specifies the exact versions of tools required/recommended for the AI Modernization Challenge.

---

## Recommended Versions (October 2025)

These are the **actively maintained, modern versions** we recommend and test against:

| Tool | Recommended | Minimum Supported | Status | Notes |
|------|-------------|-------------------|--------|-------|
| **Node.js** | 22.x LTS | 20.x LTS | Active LTS | 18.x EOL April 2025 |
| **npm** | 10.x | 9.x | Latest | Auto-installed with Node |
| **Python** | 3.13 | 3.12 | Latest stable | 3.11 works but dated |
| **Perl** | 5.34+ | 5.30+ | Stable | Standard on most systems |
| **Java** | 21 LTS | 17 LTS | LTS | **Spring Boot 3.x requires 17+** |
| **Maven** | 3.9 | 3.8 | Stable | Maven 4 in RC, not production-ready |
| **Angular** | 19 | 17 | Latest stable | Signals, incremental hydration |
| **Spring Boot** | 3.5 | 3.4 | Latest | Requires Java 17+ |

---

## Why These Versions?

### Node.js 22.x LTS ⭐ Recommended

**Release:** October 2024
**LTS Status:** Active LTS until October 2025, then Maintenance LTS until April 2027
**Why:**
- Modern ES features
- Improved performance
- Security updates
- **Node 18 LTS ends April 2025** (too soon!)

**Minimum:** Node.js 20.x LTS (Maintenance LTS until April 2026)

### Java 21 LTS ⭐ Recommended

**Release:** September 2023
**LTS Status:** Long-Term Support
**Why:**
- Virtual threads (Project Loom)
- Pattern matching for switch
- Sequenced collections
- String templates (preview)
- Fully supported by Spring Boot 3.5

**Critical:** **Java 17 is the absolute minimum** for Spring Boot 3.x
- ❌ Java 8, 11 will NOT work with Spring Boot 3.x
- ✅ Java 17 LTS works (minimum)
- ✅ Java 21 LTS works (recommended)

### Python 3.13 ⭐ Recommended

**Release:** October 2024
**Status:** Latest stable release
**Why:**
- Free-threaded mode (experimental GIL removal)
- Improved JIT compiler
- Better type hints
- Enhanced error messages
- Performance improvements

**Minimum:** Python 3.12 (stable, widely adopted)

### Angular 19 ⭐ Recommended

**Release:** November 2024
**LTS:** Will enter LTS May 2025
**Why:**
- Incremental hydration
- Stable signals API
- Improved performance
- Modern reactivity patterns

**Minimum:** Angular 17+ (signals introduced, standalone components stable)

### Spring Boot 3.5 ⭐ Recommended

**Release:** September 2025
**Status:** Latest stable
**Why:**
- Full Java 21 support
- Virtual threads support
- Modern Spring Framework 6.x
- AOT compilation improvements

**Minimum:** Spring Boot 3.4 (stable, well-tested)

### Maven 3.9 ⭐ Recommended

**Release:** Stable
**Status:** Latest production version
**Why:**
- Maven 4.0 is still in release candidate (not production-ready)
- 3.9 is mature, well-tested
- Full Java 21 compatibility

**Minimum:** Maven 3.8 (works fine, slightly older)

---

## Version Compatibility by Challenge

### Challenge 1: AngularJS → Angular

| Tool | Version Required | Notes |
|------|------------------|-------|
| Node.js | 20.x or 22.x LTS | Angular 19 requires Node 18.19+, 20.x, or 22.x |
| npm | 9.x or 10.x | Auto-installed with Node |
| Angular CLI | Latest (@angular/cli) | Install: `npm install -g @angular/cli` |
| TypeScript | 5.4+ | Included in Angular project |

**Target framework:** Angular 17+ (19 recommended)

### Challenge 2: Perl → Python

| Tool | Version Required | Notes |
|------|------------------|-------|
| Perl | 5.30+ | For running legacy script |
| Python | 3.12+ (3.13 recommended) | Target language |
| pip | Latest | Package management |

**Target framework:** Python 3.12+ with type hints, dataclasses, async

### Challenge 3: Struts → Spring Boot

| Tool | Version Required | Notes |
|------|------------------|-------|
| Java | 17 LTS minimum, 21 LTS recommended | **Spring Boot 3.x requires 17+** |
| Maven | 3.8+ (3.9 recommended) | Build tool |
| Spring Boot | 3.4+ (3.5 recommended) | Target framework |

**Critical:** The legacy Struts app uses Java 8, but your modernized Spring Boot app **must use Java 17 or higher**.

---

## EOL (End-of-Life) Dates

Know when versions become unsupported:

| Tool | Version | EOL Date | Status |
|------|---------|----------|--------|
| Node.js 18.x | LTS | April 2025 | ⚠️ EOL soon (5 months) |
| Node.js 20.x | LTS | April 2026 | ✅ Safe for now |
| Node.js 22.x | LTS | April 2027 | ✅ Active LTS |
| Java 17 | LTS | September 2029 | ✅ Long-term safe |
| Java 21 | LTS | September 2031 | ✅ Long-term safe |
| Python 3.12 | Stable | October 2028 | ✅ Safe |
| Python 3.13 | Stable | October 2029 | ✅ Safe |

---

## Installation Quick Reference

### Ubuntu/Debian (SEE Environment)

```bash
# Use our auto-installer
./scripts/setup-environment.sh

# Installs:
# - Node.js 22.x LTS
# - Python 3.12+
# - Perl 5.30+
# - Java 21 LTS
# - Maven 3.9
# - Git, curl, jq
```

### macOS

```bash
brew install node@22 python@3.13 perl openjdk@21 maven git curl jq
```

### Windows (WSL2 Ubuntu)

```bash
# Enable WSL2, install Ubuntu, then:
./scripts/setup-environment.sh
```

---

## What Our Scripts Install

When you run `./scripts/setup-environment.sh`, we install:

| Tool | Version Installed | Why This Version |
|------|------------------|------------------|
| Node.js | 22.x LTS | Latest LTS, Modern features |
| Python | 3.12+ (system) | Stable, widely available in apt |
| Java | 21 LTS | Latest LTS, Spring Boot compatible |
| Maven | 3.9 (from apt) | Latest stable in Ubuntu repos |
| Perl | 5.34+ (system) | Standard system Perl |

**Note:** We install from official repositories to ensure stability and security.

---

## Checking Your Versions

```bash
# Run our prerequisite checker
./scripts/check-prerequisites.sh

# Or check manually:
node --version      # Should show v22.x.x
npm --version       # Should show 10.x.x
python3 --version   # Should show 3.12+ or 3.13
perl --version      # Should show 5.30+
java -version       # Should show 21.x.x or 17.x.x
mvn --version       # Should show 3.9.x or 3.8.x
```

---

## Common Version Issues

### ❌ "Java 8 not working with Spring Boot 3"

**Problem:** Spring Boot 3.x requires Java 17 minimum
**Solution:** Upgrade to Java 17 LTS or 21 LTS

### ❌ "Node 18 deprecated warnings"

**Problem:** Node 18 LTS ends April 2025
**Solution:** Upgrade to Node 22.x LTS

### ❌ "Maven 4 not found"

**Problem:** Maven 4 is not released yet (only RC available)
**Solution:** Use Maven 3.9 (latest stable)

### ❌ "Python 3.11 missing features"

**Problem:** Some modern features only in 3.12+
**Solution:** Upgrade to Python 3.12 or 3.13

---

## Future-Proofing

### Coming Soon (Don't Use Yet)

- **Maven 4.0:** In release candidate, not production-ready
- **Node.js 24:** Will enter LTS October 2025
- **Java 25:** Latest but not LTS (stick with 21 LTS)

### Safe to Upgrade To

- **Python 3.13:** Latest stable, go for it!
- **Angular 19:** Latest stable, recommended
- **Spring Boot 3.5:** Latest stable, recommended

---

## Summary

**TL;DR - Use these versions:**

```
Node.js:     22.x LTS
Python:      3.13 (or 3.12 minimum)
Java:        21 LTS (or 17 LTS minimum)
Maven:       3.9
Angular:     19 (or 17 minimum)
Spring Boot: 3.5 (or 3.4 minimum)
```

**Critical rule:** Java 17+ for Spring Boot 3.x (no exceptions!)

---

**Questions?** See [PREREQUISITES.md](PREREQUISITES.md) for installation instructions.

# Challenge 2: Perl → Python

## Prerequisites

### Required Tools

- **Python 3.12+ (3.13 recommended)** - For your modernized script
- **Perl 5.30+** - To run the legacy script (for comparison)

### Installation

**Quick setup (from repo root):**
```bash
./scripts/setup-prerequisites.sh
```

This installs all required tools for all 3 challenges.

**Manual installation:** See `../../docs/PREREQUISITES.md`

---

## Overview

Modernize a legacy Perl log analyzer script to modern **Python 3.12+** (Python 3.13 recommended) with type hints, dataclasses, async patterns, and best practices.

**Recommended:** Use Python 3.13 for latest features (free-threaded mode, improved JIT). Python 3.12+ is acceptable.

## The Legacy Application

**Location:** `legacy-app/log_analyzer.pl`
**Tech Stack:**
- Perl 5.x
- ~350 lines of code
- No use strict/warnings (sloppy code)
- Global state, regex-heavy, system calls

**Features:**
- Parse application log files
- Count errors/warnings by module
- Extract and analyze IP addresses
- Track user login activity
- Analyze request timing statistics
- Output in text or JSON format

## Running the Legacy Script

```bash
cd legacy-app
chmod +x log_analyzer.pl

# Show statistics
./log_analyzer.pl ../test-inputs/app.log --stats

# Show errors
./log_analyzer.pl ../test-inputs/app.log --errors

# Multiple options
./log_analyzer.pl ../test-inputs/app.log --errors --warnings --ips

# JSON output
./log_analyzer.pl ../test-inputs/app.log --stats --json
```

## Problematic Patterns (Intentional)

### 1. **No strict/warnings**
```perl
# No "use strict" or "use warnings" - allows typos and undefined variables
$log_file = ""; # Should be "my $log_file"
```

### 2. **Global state everywhere**
```perl
%error_counts = ();  # Global hash
@all_ips = ();       # Global array
$total_lines = 0;    # Global scalar
```

### 3. **Regex-heavy parsing**
```perl
if ($line =~ /^(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s+(INFO|WARN|ERROR|DEBUG).../) {
    # Nested regexes, hard to maintain
}
```

### 4. **System calls**
```perl
my $result = `test -f $file && echo "exists"`;  # Should use -e operator
```

### 5. **Manual JSON construction**
```perl
print "{\n";
print "  \"errors\": {\n";
# Should use JSON module
```

### 6. **Perl-specific idioms**
```perl
unless ($condition) { }  # Postfix unless
next unless @times;      # Postfix modifier
$sum += $_ for @array;   # Postfix for
```

### 7. **No type safety**
Variables can be anything, no compile-time checks

### 8. **Imperative, not functional**
Lots of loops and state mutations

## Your Goal: Modern Python 3.12+

Transform this to:
- ✅ **Type hints** everywhere (PEP 484)
- ✅ **Dataclasses** for structured data
- ✅ **Pathlib** instead of string paths
- ✅ **argparse** for CLI parsing
- ✅ **json module** for JSON output
- ✅ **List comprehensions** instead of loops where appropriate
- ✅ **f-strings** for formatting
- ✅ **Context managers** for file handling
- ✅ **Optional async/await** for file I/O (bonus points)
- ✅ **pytest** testable structure

## Expected Output Structure

Your modernized code in `/output/perl-to-python/`:

```
output/perl-to-python/
├── log_analyzer.py          # Main script
├── models.py                # Dataclasses for LogEntry, Stats, etc.
├── parsers.py               # Log parsing logic
├── analyzers.py             # Analysis functions
├── formatters.py            # Output formatting
├── requirements.txt         # Dependencies (minimal!)
└── README.md                # How to run
```

## Test Data

**Input:** `test-inputs/app.log` - 50 log lines with various levels, IPs, users, timings

Your script must:
1. Parse the same log format
2. Implement all the same features
3. Produce identical outputs (text and JSON)

## Golden Outputs

We run the legacy Perl script and capture outputs:

1. **--errors** → `expected-outputs/errors.txt` & `errors.json`
2. **--warnings** → `expected-outputs/warnings.txt` & `warnings.json`
3. **--stats** → `expected-outputs/stats.txt` & `stats.json`
4. **--ips** → `expected-outputs/ips.txt` & `ips.json`
5. **--users** → `expected-outputs/users.txt` & `users.json`
6. **--times** → `expected-outputs/times.txt` & `times.json`

### ⚠️ IMPORTANT: Output Determinism Requirements

**For text outputs** (`.txt` files):
- When outputting key-value lists (e.g., error counts by module, warning counts by category), **sort keys alphabetically** to ensure consistent ordering
- Perl hashes are unordered, but your Python output must have deterministic ordering
- Example: If errors.txt shows modules in order `API, Auth, Database`, your Python must output the same order

**For JSON outputs** (`.json` files):
- JSON keys should be sorted alphabetically: use `json.dumps(data, indent=2, sort_keys=True)`
- This ensures consistent output regardless of dict insertion order
- Floating point values (like averages) should match exactly - these are deterministic from fixed input data

**Why this matters:**
Our tests compare your output text/JSON directly against golden files. Hash/dict ordering differences will cause test failures even if your data is correct. Sort your keys alphabetically!

## Running Tests

```bash
cd tests
python -m pip install -r requirements.txt
pytest -v
```

Test suites:

### Integration Tests (tests/integration/)
- Run your Python script with same inputs as Perl
- Compare stdout to golden files
- Verify exit codes match

### Unit Tests (tests/unit/)
- Type hints are correct
- Dataclasses used appropriately
- No global state
- Proper error handling
- Uses pathlib, argparse, json module

## Scoring Criteria

| Criteria | Points | How We Test |
|----------|--------|-------------|
| **Functionality** | 30 | Outputs match golden files |
| **Type Hints** | 15 | All functions/methods typed |
| **Modern Patterns** | 20 | Dataclasses, pathlib, f-strings |
| **Code Quality** | 20 | Clean, Pythonic, readable |
| **Error Handling** | 15 | Proper exceptions, not print/exit |

**Pass threshold:** 75/100 points

## Command Line Interface

Your Python script must support:

```bash
python log_analyzer.py <log_file> [options]

Options:
  --errors      Show error summary
  --warnings    Show warning summary
  --stats       Show statistics (default if none specified)
  --ips         Show IP address analysis
  --users       Show user login summary
  --times       Show request timing analysis
  --json        Output in JSON format
```

## Tips

1. **Start with models:** Define `LogEntry` dataclass with all fields typed
2. **Parse with regex:** Python's `re` module is similar to Perl
3. **Use pathlib:** `Path(file).exists()` not string operations
4. **Type everything:** Use `dict[str, int]`, `list[str]`, `Optional[T]`
5. **F-strings:** `f"Error: {count}"` not `"Error: " + str(count)`
6. **JSON module:** `json.dumps(data, indent=2)` not manual construction
7. **Context managers:** `with open(file) as f:` handles cleanup
8. **List comprehensions:** `[x for x in items if x.level == "ERROR"]`

## Common Pitfalls

❌ Using `Any` type annotation
❌ Global variables
❌ Printing errors instead of raising exceptions
❌ String concatenation instead of f-strings
❌ Manual JSON construction
❌ Not using dataclasses
❌ Missing type hints

## Bonus Points (+5)

- ✨ Async file I/O with `aiofiles`
- ✨ Rich CLI output with `rich` library
- ✨ Proper logging with `logging` module
- ✨ Click instead of argparse

---

**Good luck! Show us you can modernize real Perl code, not just write new Python.**

# Submission Validation Tools

This directory contains tools to help you validate your submission before pushing.

## For Candidates: Validate Your Submission

Before submitting your fork, run the validation script to catch common mistakes:

```bash
cd your-fork/
./validate-my-submission.sh
```

### What It Checks

The validator performs 8 comprehensive checks:

1. **SOLUTION.md** - Exists and has adequate content (100+ words)
2. **Agent Directory** - `/agent/` exists and contains your agent code
3. **Output Directory** - `/output/` exists (not `our-solution` or other names!)
4. **All 3 Challenges** - All three challenge directories exist and have content
5. **Git History** - Multiple commits showing development work (not just 1 commit)
6. **No Secrets** - No API keys, tokens, or credentials committed
7. **No Build Artifacts** - No `node_modules/` or `target/` bloat
8. **.gitignore** - Exists and doesn't exclude your output

### Expected Structure

Your fork must have this exact structure:

```
your-fork/                     ← Your GitHub fork root
├── agent/                     ← Your agent implementation
│   ├── README.md             ← How to run your agent
│   └── ... your agent code ...
├── output/                    ← MUST be named "output"
│   ├── angularjs-to-angular/  ← Challenge 1 solution
│   ├── perl-to-python/        ← Challenge 2 solution
│   └── struts-to-spring/      ← Challenge 3 solution
└── SOLUTION.md                ← Your documentation (100+ words)
```

### Common Mistakes

❌ **Wrong Directory Name**
```
your-fork/our-solution/angularjs-to-angular/  ← WRONG
```

✅ **Correct**
```
your-fork/output/angularjs-to-angular/        ← CORRECT
```

---

❌ **Nested Too Deep**
```
your-fork/eval-repo/our-solution/output/      ← WRONG
```

✅ **Correct**
```
your-fork/output/                             ← CORRECT
```

---

❌ **Wrong Challenge Names**
```
your-fork/output/angular-migration/           ← WRONG
```

✅ **Correct**
```
your-fork/output/angularjs-to-angular/        ← CORRECT
```

### Validation Output

#### ✅ Perfect Submission
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Validation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ EXCELLENT! Your submission looks perfect!

Your submission is ready to push:
  git push origin main
```

#### ⚠️ Good with Warnings
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Validation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  GOOD with 1 warning(s)

Your submission meets all requirements, but consider addressing:
  • Warnings listed above

You can submit as-is, or make improvements first.
```

#### ❌ Issues Found
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Validation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✗ ISSUES FOUND

Errors: 2 (must fix before submitting)
Warnings: 1 (recommended to fix)

Please fix the errors above before submitting your fork.
Scroll up to see specific issues and how to fix them.
```

### Helpful Error Messages

When the validator finds issues, it provides specific fix instructions:

**Example: Wrong Directory Name**
```
[3/8] Checking output directory structure...
   ❌ /output/ directory is missing

   💡 Found /our-solution/ directory
      Did you mean to name this 'output' instead?

      Fix with:
        mv our-solution output
        git add -A && git commit -m 'Fix: Rename to output'
```

**Example: Nested Too Deep**
```
[3/8] Checking output directory structure...
   ❌ /output/ directory is missing

   💡 Found /eval-repo/our-solution/output/
      Your output is nested too deep!

      Fix with:
        mv eval-repo/our-solution/output ./output
        rm -rf eval-repo/
        git add -A && git commit -m 'Fix: Move output to root'
```

### Pre-Submission Checklist

Before running the validator, ensure you:

- [ ] Completed all 3 challenges
- [ ] All challenges are in `/output/` directory
- [ ] Agent code is in `/agent/` directory
- [ ] SOLUTION.md documents your approach (100+ words)
- [ ] Committed your work with multiple commits
- [ ] Removed any API keys or secrets
- [ ] Didn't commit `node_modules/` or `target/` directories

## For Evaluators: Testing the Validator

### Run Test Suite

Test the validator against all common mistake scenarios:

```bash
cd evaluation-system/scripts/
./test-fork-scenarios-simple.sh
```

This creates 7 test repositories simulating:
1. Perfect submission (baseline)
2. Wrong directory name (`our-solution` vs `output`)
3. Nested too deep (`eval-repo/our-solution/output/`)
4. Incomplete (missing one challenge)
5. No agent directory
6. Suspicious git history (single commit)
7. Empty output directories

### Validate All Test Scenarios

```bash
cd evaluation-system/scripts/
./test-validator-all-scenarios.sh
```

Expected output:
```
Testing validation script against all scenarios...

=== Perfect submission should pass ===
✅ PASS (exit 0)

=== Wrong directory name should fail ===
✅ PASS (exit 1)

... (7 total tests) ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary: 7 passed, 0 failed
✅ All validation tests passed!
```

### Manual Testing

Test a specific scenario:

```bash
# Create test scenarios
cd evaluation-system/scripts/
./test-fork-scenarios-simple.sh

# Test specific scenario
cd ../test-forks/wrong-dirname/
/path/to/validate-my-submission.sh

# Clean up
rm -rf ../test-forks/
```

## Documentation

- **FORK_TEST_RESULTS.md** - Detailed test scenarios and findings
- **FORK_TESTING_SUMMARY.md** - Executive summary and recommendations

## Exit Codes

- `0` - Submission is valid (may have warnings)
- `1` - Submission has errors that must be fixed

## Support

If you encounter issues with the validator:

1. Make sure you're running it from your fork root (where `.git/` and `SOLUTION.md` are)
2. Check that you have `bash`, `git`, `find`, `grep` installed
3. Review error messages - they include specific fix instructions
4. See FORK_TEST_RESULTS.md for examples of each error type

## Version

Validator Version: 1.0
Last Updated: 2025-10-17

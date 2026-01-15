#!/bin/bash
#
# Validate My Submission
#
# Run this script from your fork root before submitting to catch common mistakes
#
# Usage: ./validate-my-submission.sh
#

# Don't use set -e because grep returns non-zero when no matches found
# set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

errors=0
warnings=0

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  AI Modernization Challenge${NC}"
echo -e "${BOLD}  Submission Validator${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if we're in the right place
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ ERROR: Not a git repository${NC}"
    echo "   This script must be run from your fork root directory"
    echo "   (the directory that has .git/ and SOLUTION.md)"
    exit 1
fi

echo -e "${BLUE}📍 Working directory:${NC} $(pwd)"
echo ""

#
# Check 1: SOLUTION.md exists and has content
#
echo -e "${BOLD}[1/8] Checking SOLUTION.md...${NC}"
if [ ! -f "SOLUTION.md" ]; then
    echo -e "${RED}   ❌ SOLUTION.md is missing${NC}"
    echo "      Create SOLUTION.md with your approach documentation"
    ((errors++))
else
    word_count=$(wc -w < SOLUTION.md)
    if [ "$word_count" -lt 100 ]; then
        echo -e "${YELLOW}   ⚠️  SOLUTION.md is very short ($word_count words)${NC}"
        echo "      Add more detail about your agent architecture and approach"
        echo "      Recommended: At least 100 words"
        ((warnings++))
    else
        echo -e "${GREEN}   ✓ SOLUTION.md exists ($word_count words)${NC}"
    fi
fi
echo ""

#
# Check 2: /agent/ directory exists and has content
#
echo -e "${BOLD}[2/8] Checking agent directory...${NC}"
if [ ! -d "agent" ]; then
    echo -e "${RED}   ❌ /agent/ directory is missing${NC}"
    echo "      Create an agent/ directory with your agent implementation"
    echo "      or at minimum a README.md explaining your approach"
    ((errors++))
elif [ -z "$(ls -A agent)" ]; then
    echo -e "${RED}   ❌ /agent/ directory is empty${NC}"
    echo "      Add your agent code or at minimum a README.md"
    ((errors++))
else
    agent_files=$(find agent -type f | wc -l)
    echo -e "${GREEN}   ✓ /agent/ exists with $agent_files file(s)${NC}"

    if [ ! -f "agent/README.md" ]; then
        echo -e "${YELLOW}   ⚠️  agent/README.md is missing${NC}"
        echo "      Add README.md explaining how to run your agent"
        ((warnings++))
    fi
fi
echo ""

#
# Check 3: /output/ directory exists (NOT our-solution!)
#
echo -e "${BOLD}[3/8] Checking output directory structure...${NC}"
if [ ! -d "output" ]; then
    echo -e "${RED}   ❌ /output/ directory is missing${NC}"
    echo ""

    # Help user diagnose common mistakes
    if [ -d "our-solution" ]; then
        echo -e "${YELLOW}   💡 Found /our-solution/ directory${NC}"
        echo "      Did you mean to name this 'output' instead?"
        echo ""
        echo "      Fix with:"
        echo "        ${BLUE}mv our-solution output${NC}"
        echo "        ${BLUE}git add -A && git commit -m 'Fix: Rename to output'${NC}"
    elif [ -d "eval-repo/our-solution/output" ]; then
        echo -e "${YELLOW}   💡 Found /eval-repo/our-solution/output/${NC}"
        echo "      Your output is nested too deep!"
        echo ""
        echo "      Fix with:"
        echo "        ${BLUE}mv eval-repo/our-solution/output ./output${NC}"
        echo "        ${BLUE}rm -rf eval-repo/${NC}"
        echo "        ${BLUE}git add -A && git commit -m 'Fix: Move output to root'${NC}"
    else
        echo "      Create: ${BLUE}mkdir -p output/{angularjs-to-angular,perl-to-python,struts-to-spring}${NC}"
    fi

    ((errors++))
else
    echo -e "${GREEN}   ✓ /output/ directory exists${NC}"
fi
echo ""

#
# Check 4: All three challenge outputs exist
#
echo -e "${BOLD}[4/8] Checking challenge outputs...${NC}"

required_challenges=("angularjs-to-angular" "perl-to-python" "struts-to-spring")
challenge_names=(
    "Challenge 1: AngularJS → Angular 20"
    "Challenge 2: Perl → Python 3.13"
    "Challenge 3: Struts → Spring Boot 3"
)

for i in "${!required_challenges[@]}"; do
    challenge="${required_challenges[$i]}"
    name="${challenge_names[$i]}"

    if [ ! -d "output/$challenge" ]; then
        echo -e "${RED}   ❌ Missing: output/$challenge/${NC}"
        echo "      $name is incomplete"
        ((errors++))
    elif [ -z "$(ls -A "output/$challenge" 2>/dev/null)" ]; then
        echo -e "${RED}   ❌ Empty: output/$challenge/${NC}"
        echo "      $name directory has no files"
        ((errors++))
    else
        file_count=$(find "output/$challenge" -type f | wc -l)
        echo -e "${GREEN}   ✓ output/$challenge/ ($file_count files)${NC}"
    fi
done
echo ""

#
# Check 5: Git history shows development work
#
echo -e "${BOLD}[5/8] Checking git commit history...${NC}"
commit_count=$(git log --oneline 2>/dev/null | wc -l)

if [ "$commit_count" -eq 0 ]; then
    echo -e "${RED}   ❌ No commits found${NC}"
    echo "      Make sure to commit your work!"
    ((errors++))
elif [ "$commit_count" -eq 1 ]; then
    echo -e "${RED}   ❌ Only 1 commit (SUSPICIOUS)${NC}"
    echo "      Single-commit submissions appear copied/plagiarized"
    echo "      Show your work with incremental commits:"
    echo "        - Initial setup"
    echo "        - Challenge 1 completion"
    echo "        - Challenge 2 completion"
    echo "        - Challenge 3 completion"
    echo "        - Documentation and polish"
    ((errors++))
elif [ "$commit_count" -lt 3 ]; then
    echo -e "${YELLOW}   ⚠️  Only $commit_count commits${NC}"
    echo "      More commits show your development process better"
    echo "      Recommended: At least 3-5 commits"
    ((warnings++))
else
    echo -e "${GREEN}   ✓ $commit_count commits (shows development work)${NC}"

    # Check for bulk first commit
    first_commit=$(git rev-list --max-parents=0 HEAD)
    first_commit_files=$(git diff-tree --no-commit-id --name-only -r "$first_commit" | wc -l)
    if [ "$first_commit_files" -gt 100 ]; then
        echo -e "${YELLOW}   ⚠️  First commit added $first_commit_files files${NC}"
        echo "      This looks like a bulk import - might be flagged for review"
        ((warnings++))
    fi
fi
echo ""

#
# Check 6: No secrets or credentials
#
echo -e "${BOLD}[6/8] Checking for secrets/credentials...${NC}"
secrets_found=0

# Check for API keys, passwords, tokens
if grep -r "ghp_\|github_pat_\|sk-\|AKIA\|api[_-]?key.*=\|password.*=\|secret.*=" . \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=target \
    --exclude="validate-my-submission.sh" \
    >/dev/null 2>&1; then
    echo -e "${RED}   ❌ Possible secrets/API keys found in code${NC}"
    echo "      Remove any API keys, tokens, or passwords before submitting"
    ((errors++))
    ((secrets_found++))
fi

# Check for secret files
if find . -name ".env" -o -name "*.key" -o -name "*.pem" 2>/dev/null | grep -q .; then
    echo -e "${RED}   ❌ Secret files (.env, .key, .pem) found${NC}"
    echo "      Add these to .gitignore and remove from repo"
    ((errors++))
    ((secrets_found++))
fi

if [ "$secrets_found" -eq 0 ]; then
    echo -e "${GREEN}   ✓ No obvious secrets detected${NC}"
fi
echo ""

#
# Check 7: No build artifacts committed
#
echo -e "${BOLD}[7/8] Checking for build artifacts...${NC}"
bloat_found=0

if [ -d "node_modules" ] || find output -name "node_modules" -type d 2>/dev/null | grep -q .; then
    echo -e "${YELLOW}   ⚠️  node_modules/ directories found${NC}"
    echo "      Add to .gitignore to reduce repo size"
    ((warnings++))
    ((bloat_found++))
fi

if [ -d "target" ] || find output -name "target" -type d 2>/dev/null | grep -q .; then
    echo -e "${YELLOW}   ⚠️  Maven target/ directories found${NC}"
    echo "      Add to .gitignore to reduce repo size"
    ((warnings++))
    ((bloat_found++))
fi

if [ "$bloat_found" -eq 0 ]; then
    echo -e "${GREEN}   ✓ No build artifacts committed${NC}"
fi
echo ""

#
# Check 8: Recommended .gitignore patterns
#
echo -e "${BOLD}[8/8] Checking .gitignore...${NC}"
if [ ! -f ".gitignore" ]; then
    echo -e "${YELLOW}   ⚠️  No .gitignore file${NC}"
    echo "      Recommended patterns:"
    echo "        node_modules/"
    echo "        target/"
    echo "        .env"
    echo "        *.key"
    echo "        *.pem"
    ((warnings++))
else
    echo -e "${GREEN}   ✓ .gitignore exists${NC}"

    # Check for dangerous patterns that might exclude output
    if grep -E "^output/$|^output$" .gitignore >/dev/null 2>&1; then
        echo -e "${RED}   ❌ .gitignore excludes 'output/' directory!${NC}"
        echo "      Remove this pattern - it's hiding your submission"
        ((errors++))
    fi
fi
echo ""

#
# Final Summary
#
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Validation Summary${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✓ EXCELLENT!${NC} ${GREEN}Your submission looks perfect!${NC}"
    echo ""
    echo "Your submission is ready to push:"
    echo "  ${BLUE}git push origin main${NC}"
    echo ""
    exit 0

elif [ $errors -eq 0 ]; then
    echo -e "${YELLOW}${BOLD}⚠️  GOOD${NC} ${YELLOW}with $warnings warning(s)${NC}"
    echo ""
    echo "Your submission meets all requirements, but consider addressing:"
    echo "  • Warnings listed above"
    echo ""
    echo "You can submit as-is, or make improvements first."
    echo ""
    exit 0

else
    echo -e "${RED}${BOLD}✗ ISSUES FOUND${NC}"
    echo ""
    echo -e "${RED}Errors: $errors (must fix before submitting)${NC}"
    echo -e "${YELLOW}Warnings: $warnings (recommended to fix)${NC}"
    echo ""
    echo "Please fix the errors above before submitting your fork."
    echo "Scroll up to see specific issues and how to fix them."
    echo ""
    exit 1
fi

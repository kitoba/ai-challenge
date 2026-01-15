# Quick Start Guide

Get up and running in under 5 minutes.

---

## 🎯 Step 0: Use SEE (Recommended)

**We strongly recommend using Nationwide's Software Engineering Environments (SEE):**

1. **Access:** [https://see.nwie.net/](https://see.nwie.net/)
2. **Help:** [Getting Started Guide](https://minerva.nwie.net/catalog/default/component/software-engineering-environments/docs/getting-started)

Once in SEE:
```bash
# Clone the repo
git clone <this-repo>
cd ai-modernization-challenge

# One-step setup (installs all tools)
./scripts/setup-prerequisites.sh
```

**Using your own machine?** You're responsible for setup. Continue to Step 1.

---

## Step 1: Install Prerequisites

```bash
# One command to install everything
./scripts/setup-prerequisites.sh
```

This script:
- Auto-detects SEE (uses nwx) or personal machine (uses sudo)
- Installs Node.js, Python, Java, Maven
- Verifies everything works

**⚠️ Note:** We don't provide support for environment issues. If you can't configure basic developer tools, this challenge may not be for you.

## Step 2: Verify Legacy Apps Work

### Test AngularJS App (Challenge 1)
```bash
cd challenges/1-angularjs-to-angular/legacy-app
npm install
npm run serve
# Open http://localhost:8080 in browser
# Ctrl+C to stop
cd ../../..
```

### Test Perl Script (Challenge 2)
```bash
cd challenges/2-perl-to-python
perl legacy-app/log_analyzer.pl test-inputs/app.log --stats
cd ../..
```

### Test Struts App (Challenge 3) - Optional
```bash
cd challenges/3-struts-to-spring/legacy-app
mvn clean package
mvn jetty:run
# Open http://localhost:8080/products
# Ctrl+C to stop
cd ../../..
```

## Step 3: Create Your Workspace

```bash
mkdir -p agent output
```

**Directory structure:**
```
your-fork/
├── agent/                    # Your AI agent code goes here
├── output/                   # Your modernized code goes here
│   ├── angularjs-to-angular/
│   ├── perl-to-python/
│   └── struts-to-spring/
├── challenges/               # Don't modify these
└── SOLUTION.md               # Explain your approach
```

## Step 4: Build Your Agent System

Start with Challenge 1 (easiest), then complete all three:

```bash
cd challenges/1-angularjs-to-angular
cat README.md  # Read the requirements
# Remember: You must complete ALL THREE challenges!
```

**Your agent(s) should:**
1. Read the legacy code in `legacy-app/`
2. Analyze patterns and structure
3. Generate modern code in `../../output/angularjs-to-angular/`
4. Pass tests in `tests/`

**Note:** Use whatever agent architecture works best—single agent, specialized agents for different tasks, whatever you design.

## Step 5: Test Your Output

### Challenge 1: Angular
```bash
cd challenges/1-angularjs-to-angular/tests
npm install
npm test
```

### Challenge 2: Python
```bash
cd challenges/2-perl-to-python/tests
pytest
```

### Challenge 3: Spring Boot
```bash
cd challenges/3-struts-to-spring/tests
mvn test
```

## Step 6: Repeat for All 3 Challenges

**CRITICAL:** You must complete **ALL THREE CHALLENGES** to be considered for the role.

This is NOT optional. Completing only one or two shows you can build single-purpose tools. We need engineers who can build general-purpose transformation systems that work across different tech stacks.

## Tips for Success

1. **Start simple:** Get Challenge 1 working first, then adapt your approach
2. **Test often:** Run tests after every major change
3. **Handle errors:** LLMs will fail—build retry logic and error handling
4. **Document:** Keep notes for your SOLUTION.md
5. **Time management:** You have 48 hours—don't perfect one, get all three working

## Troubleshooting

**"Command not found" errors:**
```bash
./scripts/check-prerequisites.sh
```

**Tests failing:**
- Check expected-outputs/ to see what's expected
- Compare your output structure to the legacy app
- Read the challenge README carefully

**Need to reset:**
```bash
rm -rf output/*
rm -rf node_modules/
```

## Next Steps

- Read the full [README.md](README.md)
- Review [SUBMISSION_GUIDE.md](SUBMISSION_GUIDE.md)
- Check individual challenge READMEs
- See [docs/PREREQUISITES.md](docs/PREREQUISITES.md) for detailed setup

---

**Ready? Start building!**

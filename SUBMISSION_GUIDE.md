# Submission Guide

## How to Submit Your Solution

### 1. Fork This Repository

```bash
gh repo fork keckm1/ai-modernization-challenge
cd ai-modernization-challenge
```

### 2. Create Your Agent System

Build your AI agent in the `/agent/` directory:

```
your-fork/
├── agent/
│   ├── src/                    # Your agent source code
│   ├── requirements.txt        # Python dependencies
│   ├── package.json            # Or Node.js dependencies
│   └── README.md               # How to run your agent
├── output/
│   ├── angularjs-to-angular/   # Your modernized Angular app
│   ├── perl-to-python/         # Your modernized Python script
│   └── struts-to-spring/       # Your modernized Spring Boot app
├── SOLUTION.md                 # Required: Explain your approach
└── challenges/                 # Don't modify
```

### 3. Run Your Agent(s)

Your agent should:
1. Read the legacy code from `/challenges/[challenge]/legacy-app/`
2. Analyze and understand the patterns
3. Generate modernized code in `/output/[challenge]/`
4. Validate against provided tests

### 4. Run Tests

For each challenge:

```bash
# Challenge 1: AngularJS → Angular
cd challenges/1-angularjs-to-angular/tests
npm install && npm test

# Challenge 2: Perl → Python
cd challenges/2-perl-to-python/tests
pip install -r requirements.txt && pytest -v

# Challenge 3: Struts → Spring Boot
cd challenges/3-struts-to-spring/tests
mvn test
```

Document your test results in `SOLUTION.md`.

### 5. Complete SOLUTION.md

**Required sections:**

```markdown
# Solution

**Name:** Your Name
**Email:** your.email@nationwide.com
**Time Spent:** ~XX hours

## Approach

[Describe your agent architecture and strategy]

## Challenges Completed

- [x] Challenge 1: AngularJS → Angular
- [x] Challenge 2: Perl → Python
- [x] Challenge 3: Struts → Spring Boot

## Test Results

### Challenge 1
- Behavioral tests: XX/YY passing
- Unit tests: XX/YY passing
- Notes: [Any failures or issues]

### Challenge 2
[Repeat for each challenge]

## Agent Architecture

[Explain your system design]

## Key Design Decisions

[List major decisions and tradeoffs]

## Challenges Faced

[What was difficult? How did you solve it?]

## What I'd Improve With More Time

[Honest assessment]

## How to Run My Agent

```bash
cd agent
[Your instructions]
```
```

### 6. Ensure Repository Access

Make sure your fork is either:
- **Public**, OR
- **Accessible to user `keckm1`**

### 7. Submit

email your fork URL to: keckm1@nationwide.com

**Deadline:** 48 hours from when you start

---

## Submission Checklist

Before submitting, verify:

- [ ] All three challenges completed
- [ ] Your complete outputed code in `/output/angularjs-to-angular/`, `/output/perl-to-python/`, `/output/struts-to-spring/`
- [ ] Agent code in `/agent/` with clear README (this doesn't have the be the agent's run location, but I want to be able to inspect your agents)
- [ ] `SOLUTION.md` completed with all sections
- [ ] Tests run (document results even if not all passing)
- [ ] No secrets/credentials in repository
- [ ] Repository is accessible to `keckm1`

---

## What Happens Next

1. **Week 1:** We evaluate all submissions
2. **Scoring:** Based on rubric (see evaluation/scoring-rubric.md in eval repo)
3. **Top candidates:** Invited to interview
4. **Timeline:** Responses within 1 week of deadline

---

## FAQs

**Q: Do ALL tests need to pass?**
A: No. We evaluate holistically. 75+ points (out of 100) is the interview threshold. Agent quality and approach matter as much as perfect test scores.

**Q: Can I use existing frameworks?**
A: Absolutely! LangChain, CrewAI, Autogen, or custom - use whatever works.

**Q: What if I can't complete all three?**
A: The challenge is designed for all three. Completing only one shows single-purpose tooling; all three shows general-purpose capability. We're looking for the latter.

**Q: Can I modify the test data?**
A: No. Use the provided test data as-is.

**Q: How long should this take?**
A: Most top candidates spend 20-30 hours over the 48-hour window.

**Q: Can I ask questions?**
A: No. Handling ambiguity is part of the challenge.

---

## Evaluation Criteria Reminder

| Category | Weight |
|----------|--------|
| **Functionality** | 30% - Do outputs match golden files? |
| **Agent Quality** | 25% - Architecture, reasoning, robustness |
| **Code Quality** | 20% - Idiomatic, maintainable modern code |
| **Security** | 15% - No vulnerabilities introduced |
| **Reliability** | 10% - Consistent, handles edge cases |

**Remember:** We're evaluating your ability to build AI systems that work across different tech stacks, not just prompt engineering skills.

---

**Good luck! We're excited to see what you build.**

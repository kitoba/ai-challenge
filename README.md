# AI Modernization Challenge
## Call to Action

> *"We're looking for engineers who don't just use AI tools—they build them."*

---

## The Challenge

Build an AI agent system that can **automatically modernize legacy codebases across different languages and frameworks** while maintaining functionality, quality, and security.

**Time Limit:** 48 hours from your registered start time
**What You'll Build:** An agent system that successfully modernizes all three legacy applications
**The Test:** Can you build a system that works across AngularJS, Perl, AND Java/Struts?
**The Prize:** Direct interview for a lead AI engineering role at Nationwide

---

## The Three Challenges

**⚠️ IMPORTANT: You must complete ALL THREE challenges.**

Your agent(s) must successfully modernize **all three** legacy applications. This tests your ability to build truly general-purpose transformation systems, not just single-language solutions:

### 1. AngularJS → Modern Angular
Transform a legacy AngularJS 1.x application into modern Angular 18+ with TypeScript.
- **Difficulty:** ⭐⭐⭐⚪⚪
- **Size:** ~2,500 LOC
- **Tech:** AngularJS → Angular 18+ (20 recommended), standalone components, signals

[→ Start Challenge 1](challenges/1-angularjs-to-angular/)

### 2. Perl → Python
Convert a legacy Perl application to modern Python 3.12+ with type hints.
- **Difficulty:** ⭐⭐⭐⭐⚪
- **Size:** ~1,800 LOC
- **Tech:** Perl 5.x → Python 3.12+ (3.13 recommended), type hints, async patterns

[→ Start Challenge 2](challenges/2-perl-to-python/)

### 3. Struts → Spring Boot
Modernize an Apache Struts application to Spring Boot 3.4+ with Java 21.
- **Difficulty:** ⭐⭐⭐⭐⭐
- **Size:** ~3,000 LOC
- **Tech:** Struts 1.x → Spring Boot 3.4+ (3.5 recommended), Java 21 LTS, REST APIs

[→ Start Challenge 3](challenges/3-struts-to-spring/)

---

## Getting Started

### 1. Set Up Your Environment

**🎯 Recommended: Use Nationwide SEE**

We **strongly recommend** using Nationwide's Software Engineering Environments (SEE) for this challenge:

- **Access:** [https://see.nwie.net/](https://see.nwie.net/)
- **Help:** [Getting Started Guide](https://minerva.nwie.net/catalog/default/component/software-engineering-environments/docs/getting-started)
- **Why?** Pre-configured, standardized, zero setup required

**Alternative: Personal Machine**

If you prefer your own environment, you're responsible for setup and troubleshooting. We won't provide support for environment issues—that's part of the challenge.

**One-step setup:**
```bash
./scripts/setup-prerequisites.sh
```

This script:
- Auto-detects SEE (uses nwx) or personal machine (uses sudo)
- Installs all required tools: Node.js, Python, Perl, Java, Maven
- Verifies everything works

**Required tools:**
- Node.js 20+ and npm (22.x LTS recommended) - Challenge 1
- Python 3.12+ (3.13 recommended) - Challenge 2
- Perl 5.30+ - Challenge 2
- Java 17+ (21 LTS recommended) and Maven 3.8+ - Challenge 3
- Git, curl, jq

See [docs/PREREQUISITES.md](docs/PREREQUISITES.md) for detailed information or [QUICKSTART.md](QUICKSTART.md) for a 5-minute guide.

**AI Tools & Model Access**

This challenge assumes you're already working with AI tools in your day-to-day work. You should have your preferred AI development environment configured and ready—whether that's Claude Code with Bedrock, GitHub Copilot, or other approved tools. Setting up IAM permissions, configuring model access, and navigating Nationwide's AI governance is expected knowledge for this role. If you're still getting set up with AI tooling, that's a signal this role may not be the right fit yet.

### 2. Set up your workspace
```bash
# Create your agent directory
mkdir -p agent output
```

### 3. Start with Challenge 1 (then do all three)
```bash
# Start with the easiest, then complete all three
cd challenges/1-angularjs-to-angular
cat README.md
```

### 4. Build your agent system
Your agent(s) should:
- Analyze the legacy codebase
- Understand patterns and architecture
- Transform code to modern framework
- Validate against provided tests
- Output clean, maintainable code

**Note:** You can use a single agent, multiple specialized agents, or any architecture that works. We evaluate the system you build.

### 5. Run the tests
```bash
cd challenges/[your-choice]/tests
# Follow test instructions in challenge README
npm test  # or pytest or mvn test
```

### 6. Submit your solution
When your tests pass and you're ready:
1. Push all changes to your repo before your 48-hour deadline
2. Ensure your repo is public or accessible to `keckm1`
3. Email keckm1@nationwide.com with:
   - Subject: "AI Challenge Submission - [Your Name]"
   - Repo URL
   - Brief confirmation you're done

**Deadline:** 48 hours from your registered start time. Commits after your deadline will be ignored.

---

## Repository Structure

```
your-fork/
├── agent/                    # Your AI agent system
│   ├── src/                  # Agent source code or markdown
│   ├── requirements.txt      # Python deps (or package.json for Node)
│   └── README.md             # How to run your agent
├── output/                   # Your modernized code (all 3 challenges)
│   ├── angularjs-to-angular/
│   ├── perl-to-python/
│   └── struts-to-spring/
├── challenges/               # The challenges (don't modify)
│   ├── 1-angularjs-to-angular/
│   ├── 2-perl-to-python/
│   └── 3-struts-to-spring/
├── SOLUTION.md               # Explain your approach (required)
└── README.md                 # This file
```

---

## Evaluation Criteria

Your submission will be scored on **100 points**:

| Category | Points | What We Evaluate |
|----------|--------|------------------|
| **Functionality** | 30 | Do the tests pass? Feature parity? |
| **Agent Quality** | 25 | Architecture, reasoning, error handling |
| **Code Quality** | 20 | Idiomatic, maintainable, clean |
| **Security** | 15 | No vulnerabilities, secure practices |
| **Reliability** | 10 | Consistent results, edge cases |

**Interview threshold:** 75+ points

---

## What We're Looking For

### You're a great fit if you:
- Have built AI agent systems (single-agent, multi-agent, LangChain, CrewAI, AutoGen, custom frameworks)
- Understand software architecture deeply
- Can work across multiple languages/frameworks
- Think about testing, quality, and security first
- Don't give up when LLMs hallucinate or fail
- Love turning complexity into elegant solutions

### You might struggle if you:
- Only prompt engineer, don't code
- Need hand-holding or extensive documentation
- Give up easily when things break
- Don't test your work
- Can't handle ambiguity

---

## Rules

1. **Time limit:** 48 hours from your registered start time (individual windows)
2. **Deadline:** Commits after your 48-hour window will be ignored (we check git timestamps)
3. **Use any tools:** Claude Opus 4.5, GPT-5, Gemini 2.5, LangChain, CrewAI, whatever makes sense
4. **No collaboration:** Solo work only
5. **No questions:** Part of the challenge is handling ambiguity
6. **No sharing:** Keep your approach confidential until challenge period ends
7. **Must include:** Working code + SOLUTION.md explaining your approach

---

## Quick FAQ

**📚 [See Full FAQ →](FAQ.md)** - Detailed answers to setup, architecture, and submission questions

### Common Questions

**Q: Do I need to complete all three challenges?**
A: **YES - ALL THREE ARE REQUIRED.** This is non-negotiable. The whole point is building an agent system that can handle different tech stacks. Completing only one or two shows you can build single-purpose tools; completing all three shows you can build a general-purpose transformation system. We will NOT evaluate partial submissions.

**Q: Can I use existing AI frameworks?**
A: Absolutely! Use whatever tools make sense. We evaluate the system you build.

**Q: What if my tests don't all pass?**
A: That's okay. We evaluate holistically—agent quality and approach matter too.

**Q: How much time should I spend?**
A: You have 48 hours from when you register your start time. Most top candidates use 20-30 hours. This isn't about speed—it's about building a robust system that works across all three challenges. Start with one, get it working, then generalize your approach.

**Q: Can I add features beyond the tests?**
A: Sure, but focus on passing the provided tests first.

**Q: What programming languages can I use for my agent?**
A: Any language. Python and TypeScript are common, but use what you're best at.

**Q: What if I have environment setup issues?**
A: Use [Nationwide's SEE environment](https://see.nwie.net/)—it's pre-configured and ready to go. If you choose to use your own machine, troubleshooting environment issues is your responsibility. Part of this challenge is demonstrating you can work independently with standard developer tools.

**Q: Can you help me install Java/Maven/Node.js?**
A: No. Use SEE (recommended) or configure your own environment. We provide scripts (`./scripts/check-prerequisites.sh`) to check your setup, but support for personal machine configuration is not available.

**Q: Can I use multiple agents?**
A: Yes! Use whatever architecture works - single agent, multi-agent, whatever you design.

**More questions?** See the **[Complete FAQ](FAQ.md)** for detailed answers on agent architecture, environment setup, testing, submission, and what we will/won't help with.

---

## Submission Checklist

Before submitting:
- [ ] Agent code is in `/agent/` directory with clear README
- [ ] **All three** modernized codebases in `/output/`:
  - [ ] `/output/angularjs-to-angular/` (Angular tests passing)
  - [ ] `/output/perl-to-python/` (Python tests passing)
  - [ ] `/output/struts-to-spring/` (Spring Boot tests passing)
- [ ] Tests have been run for all three and results documented
- [ ] SOLUTION.md explains your approach and architecture
- [ ] No secrets/credentials in repo
- [ ] Repo is public or accessible to `keckm1`

---

## Tips for Success

1. **Start with one, then complete all three:** Start with the easiest (AngularJS), get it fully working, then adapt your approach for the other two. You MUST complete all three.
2. **Build reusable components:** Your agent architecture should handle different languages—don't build three completely independent tools with no shared logic
3. **Test early and often:** Run the provided tests frequently for each challenge
4. **Handle errors gracefully:** LLMs will fail—your agent(s) should recover across all three tech stacks
5. **Document decisions:** Explain your reasoning in logs and SOLUTION.md
6. **Security matters:** Scan your output for vulnerabilities in all three outputs
7. **Idiomatic code:** Modern frameworks have conventions—follow them for each target framework
8. **Time management:** Don't perfect one challenge—get all three working, then improve

---

## Support Policy

**Environment Setup:** Use [SEE](https://see.nwie.net/) (recommended) or self-configure. No support provided for personal machine setup.

**Challenge Questions:** Not allowed—handling ambiguity is part of the test.

**Bug Reports:** If you find actual bugs in the challenge code (not your agent(s)), create an issue.

**After Submission:** We'll contact you within 1 week with results.

---

## Confidentiality

This challenge is internal to Nationwide. Please don't share publicly or on social media.

---

**Good luck. Build something that matters.**

*— Matthew Keck, Chief Architect, Nationwide P&C Technology*

---

## About This Role

You'll be joining a team that's redefining how thousands of Nationwide developers build software. We're building AI-native tooling at scale—agents that understand our codebases, refactor safely, and ship production-quality code.

**The coin of greatness is never easy.**

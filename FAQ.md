# Frequently Asked Questions

Answers to common questions about the AI Modernization Challenge.

---

## 📋 Challenge Requirements

### Q: Do I really need to complete all three challenges?
**A: YES - ALL THREE ARE REQUIRED.** This is non-negotiable. Partial submissions may not be evaluated depending on number of full submissions received.

We're testing your ability to build general-purpose AI agent systems, not single-purpose tools. Completing one challenge proves you can handle one tech stack. Completing all three proves you can build systems that work across different languages and frameworks.

### Q: What's the time limit?
**A: 48 hours from when you register your start time.** Email keckm1@nationwide.com with "Starting AI Challenge - [Your Name]" to begin your clock. Your last git commit must be before your 48-hour deadline - we verify timestamps!

### Q: Can I submit if some tests don't pass?
**A: Yes, but it will affect your score.** We evaluate holistically - a great agent architecture with mostly passing tests is better than manually perfect code. Document what's failing and why in your SOLUTION.md.

### Q: What counts as "completion"?
**A: All three modernized codebases in `/output/` that demonstrate real migration attempts.**

Minimum requirements:
- Code compiles/runs (or explains why not)
- Shows understanding of modern frameworks
- Demonstrates agent usage (not manual conversion)
- Passes majority of verification tests

----

## 🤖 Agent Architecture

### Q: Can I use multiple agents?
**A: Absolutely!** Use whatever architecture makes sense - single agent, multi-agent, orchestrated pipeline, whatever you design. We evaluate the system you build.

Examples of valid approaches:
- One general-purpose migration agent
- Specialized agents (sorry no hints, think how you woudl do this if you were in charge of the effort!)
- Agent pipelines with orchestration
- Iterative agent workflows

### Q: What AI frameworks can I use?
**A: Any you want.** LangChain, LangGraph, CrewAI, Autogen, Claude Code, custom frameworks - use what you're comfortable with. We evaluate results, not the tools.

### Q: What programming language should I write my agent(s) in?
**A: Any language.** Markdown, Python, and TypeScript are common for AI agents, but use what you're best at. Your agent "code" lives in `/agent/` - structure it however makes sense.

### Q: Do you care about my agent code quality?
**A: Yes, but output quality matters more.** We review your agent architecture for insights into your thinking, but the primary evaluation is the quality of the modernized code your agents' produce.

---

## 🛠️ Environment & Setup

### Q: What environment should I use?
**A: Nationwide SEE (recommended) or your own machine.**

**Recommended:** Use SEE ([https://see.nwie.net/](https://see.nwie.net/))
- Pre-configured with all tools
- Zero setup required
- Same environment we use for evaluation

**Alternative:** Personal machine
- You're responsible for setup
- No support provided
- Must have: Node 22, Python 3.13, Java 21, Maven 3.9

### Q: Can you help me install Node.js / Java / Python?
**A: No.** Use SEE (recommended) or configure your own environment. Part of this challenge is demonstrating you can work independently with standard developer tools.

We provide:
- ✅ `./scripts/setup-prerequisites.sh` (auto-installer)
- ✅ `./scripts/check-prerequisites.sh` (verification)
- ✅ Detailed docs in `docs/PREREQUISITES.md`

We do NOT provide:
- ❌ Help installing tools on your personal machine
- ❌ Debugging your environment issues
- ❌ Support for non-standard setups

### Q: What if I have environment issues in SEE?
**A: Contact SEE support.** They can help with SEE-specific issues. We don't provide environment troubleshooting.

### Q: My tests are failing - can you help?
**A: No.** Debugging your code and agent output is part of the challenge. The test failures are telling you what's wrong - figure it out!

What we provide:
- ✅ Clear test expectations in each challenge README
- ✅ Golden output files to compare against
- ✅ Working legacy apps you can run and analyze

What we won't do:
- ❌ Debug your code
- ❌ Explain why your tests are failing
- ❌ Give hints about what's wrong

---

## 📚 Challenge-Specific Questions

### Q: Challenge 1 - Do I need to use Angular 20 exactly?
**A: Angular 18+ is acceptable, 20 is recommended.** Use the latest stable version you're comfortable with. Angular 19 or 20 are both great choices.

### Q: Challenge 1 - What about NgModules vs Standalone?
**A: Use standalone components.** This is the modern Angular approach (post-Angular 14). No NgModules.

### Q: Challenge 2 - Is async/await required?
**A: No, it's optional bonus points.** The base requirement is Python 3.12+ with type hints. Async file I/O is nice-to-have.

### Q: Challenge 2 - My output order is different from golden files
**A: Sort your keys alphabetically!** See the README section "⚠️ IMPORTANT: Output Determinism Requirements". Use `json.dumps(data, sort_keys=True)` and sort dict keys for text output.

### Q: Challenge 3 - Can I use Spring Boot 3.5?
**A: Yes, 3.4+ is the requirement.** Use 3.5 if you want the latest features.

### Q: Challenge 3 - What about the Struts legacy app?
**A: You don't need to run it, just analyze the code.** It's there if you want to see it work, but analyzing the source code is sufficient.

---

## 🚫 What We Won't Help With

### Technical Implementation
- ❌ How to write prompts for your agents
- ❌ Which AI framework to choose
- ❌ How to structure your code
- ❌ Debugging your agent logic
- ❌ Why your migration isn't working

### Environment Setup
- ❌ Installing tools on your personal machine
- ❌ Fixing PATH issues
- ❌ Java version conflicts
- ❌ Node.js installation problems
- ❌ Maven configuration

### Challenge Interpretation
- ❌ "What does this legacy pattern mean?"
- ❌ "How should I handle X in the migration?"
- ❌ "Is this the right approach?"
- ❌ Clarifying requirements beyond what's in the README

**Why?** Handling ambiguity and figuring things out independently is part of what we're testing.

---

## ✅ What We WILL Help With

### Actual Bugs in Our Code
**If you find a bug in the challenge materials** (not your code):
- ✅ Legacy app doesn't run
- ✅ Test harness is broken
- ✅ Golden outputs are incorrect
- ✅ Documentation has errors

**How to report:** Create an issue in the repo with:
- What's broken
- How to reproduce
- What you expected vs what happened

### SEE Access Issues
**If you can't access SEE:**
- ✅ Contact your IT support or SEE help desk
- ✅ We can verify you have correct permissions

### Submission Process
**If you have questions about submitting:**
- ✅ How to make repo accessible
- ✅ What to include in SOLUTION.md
- ✅ Where to email your submission
- ✅ Clarifying submission requirements

---

## 📤 Submission

### Q: How do I submit?
**A: Push your code before the deadline, then email matthew.keck@nationwide.com**

Steps:
1. **Push all changes** to your fork before the deadline
2. **Ensure last commit** is before the cutoff time (we check git timestamps)
3. **Email** matthew.keck@nationwide.com with:
   - Subject: "AI Challenge Submission - [Your Name]"
   - Your fork URL (public or with keckm1 as collaborator)
   - Brief confirmation you're done

### Q: What should be in my SOLUTION.md?
**A: Explain your agent architecture and approach.**

Minimum content:
- Agent architecture (single vs multi-agent, orchestration, tools used)
- Design decisions and tradeoffs
- Challenges faced and how you overcame them
- Test results summary
- Rough time spent

### Q: Can I submit updates after initial submission?
**A: You can push updates until the deadline.** Your last commit before the deadline is what we'll evaluate. Once the deadline passes, no more commits will be accepted - we verify git timestamps!

### Q: What if I need more than 48 hours?
**A: Contact me BEFORE the deadline if there's an emergency.** The 48-hour fixed window is there for fairness to all candidates, but we understand life happens. Reach out before the deadline if you have extenuating circumstances.

---

## 🎯 Evaluation

### Q: What's the interview threshold?
**A: 75+ out of 100 points.**

Scoring breakdown:
- Functionality: 30 points
- Agent Quality: 25 points
- Code Quality: 20 points
- Security: 15 points
- Reliability: 10 points

### Q: What matters most?
**A: Agent architecture > Code quality > Tests passing**

We're hiring AI engineers, not traditional developers. A brilliant agent system that produces good code, repeatedly and can handle new requirements and feature add ons, is more valuable than manually perfect code.

### Q: Do I need 100% test coverage?
**A: No.** 75%+ passing tests with great agent architecture beats 100% tests with poor/manual approach (i'll know if you did it manually, there are safeguards :D)

### Q: How long until I hear back?
**A: Within 1 week of submission.** Hopefully ... I'll email results and next steps and whether this got you into the interview process.

---

## 🤔 Philosophy Questions

### Q: Why can't I ask questions during the challenge?
**A: Because handling ambiguity is part of what we're testing.**

In production AI engineering:
- Requirements are often unclear
- Legacy code is undocumented
- You need to figure things out independently
- There's no one to ask "is this right?"

This challenge simulates that reality.

### Q: Why no environment support?
**A: Because we need engineers who can handle standard dev tools independently.**

If you can't install Node.js, Java, and Python independently, this role will be very hard. We provide SEE as a pre-configured option specifically to remove this barrier.

### Q: Isn't this unfair to people without AI experience?
**A: No - we're explicitly hiring for AI engineering skills.**

The job is building AI agent systems at scale. If you don't have experience with AI agents, this role isn't a fit. That's intentional.

---

## 💡 Tips That Aren't "Helping"

These are general good practices, not specific to our challenges:

**General AI Engineering:**
- Test your agents iteratively, don't build everything at once
- Handle LLM failures gracefully with retries and fallbacks
- Log agent reasoning for debugging
- Validate outputs automatically
- Use version control for agent iterations

**Challenge Strategies:**
- Start with the easiest (Challenge 1)
- Build reusable components that work across challenges
- Don't perfect one challenge - get all three working first
- Read the legacy code to understand patterns before migrating
- Compare your output to golden files frequently

**Time Management:**
- Plan for ~8-10 hours per challenge
- Budget time for debugging and iteration
- Don't get stuck - move on and come back
- Document as you go (for SOLUTION.md)

---

## 📞 Still Have Questions?

**Before asking:**
1. Read this FAQ thoroughly
2. Check the main [README.md](README.md)
3. Review the specific challenge README
4. Check [docs/PREREQUISITES.md](docs/PREREQUISITES.md)
5. Review [SUBMISSION_GUIDE.md](SUBMISSION_GUIDE.md)

**If you still have a question:**
- Email: keckm1@nationwide.com
- Subject: "AI Modernization Challenge - Question"
- **Note:** We'll only answer questions about the submission process, actual bugs in our code, or SEE access. We won't help with technical implementation or environment setup.

---

**Remember:** Part of this challenge is demonstrating you can work independently with minimal guidance. That's what this role requires.

**Good luck!**

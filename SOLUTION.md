# Solution Template

**Candidate Name:** Christopher Sunami
**Challenge(s) Attempted:** 1, 2, and 3
**Time Spent:** 20 hrs
**Submission Date:** 1/15/26

---

## Approach Overview

I decided to go with a custom approach rather than using tooling--that's largely a matter of personal preference. I always like to at least try building on my own, it helps me understand what's going on, although I do realize that in the corporate environment, we need standardized approaches. However, given the youth of the AI field, the rapid state of change, and the immaturity of the tooling, I think there's still a good argument for custom. (SPOILER ALERT: Probably not the right decision in this case).

I also decided to try to build a general system rather than one that was tightly coupled or did any direct, one-to-one translations. Again, it seemed like a more interesting and powerful approach. Accordingly what my project (attempts) to do is to analyze the source from two contrasting perspectives, synthesize those into a usuable report, both human and machine-readable, and then rebuild from scratch. Theoretically this would allow not just modernization within a lane, but universal translation. (SPOILER ALERT: Too amibitious for the timeframe)

I started with the Angular project, although in retrospect, the perl project would have probably been a better place to prove out this approach. I tried to build with reusability in mind. The biggest conceptual issue was how to best deploy the LLMs, so that they had a good understanding of the whole project but weren't overwhelmed. As the deadline approached, I had something that would create a modern angular project that would at least compile and run, and that had some of the major elements, but was not in a perfected state. I decided to make a late pivot to at least proofing out the capacity for multiple models, and used my remaining time to do that.

---

## Architecture

### Components

- Analyzer: general class to consume a code parser
- AngularCodeParser: specialized reader for angularjs
- Generator: Generates new code from the reports
- Modernizer: An Agent that orchestrates the flow from Analysis to Generation
- MultModernizer: Builds different Modernizers for different code bases
- MultiFactory: Creates all the MultiModernizers
- OpenRouterClient: Connects to the LLMs
- PerlCodeParser: (NOT COMPLETED)
- ReportParser: Compiles the reports on the legacy code
- RSReadWrite: Interacts with the file system
- TestParser: Analyzes the tests for clues as to code behavior

---

## Key Design Decisions

See above

---

## Challenges & Solutions

I started the process with a huge disadvantage. Although I have extensive professional work at NW in AI, it is mostly from the pre-modern era, and my work with agentic AI has been on my personal time, so I wasn't onboarded onto any of the NW tooling. However, rather than giving up, I decided to complete the challenge in my personal environment. Since the LLM integration is through API calls, it should be simple to get this working in the NW environment.

The other challenge was selecting the proper LLMS. As you can imagine, the results varied widely with the LLM selection, not so much at the analysis level, but in creating new code.

---

## Test Results

I wasn't able to complete the tasks

---

## Code Quality

[Self-assessment of your output code]

- **Idiomatic?** [Yes/No - explain]
- **Maintainable?** [Yes/No - explain]
- **Security considerations:** [What you checked]

---

## What I'd Improve With More Time


The big aspect to the design I wasn't able to implement was an iteration loop that would go through, fix errors, run the test suite, and keep iterating until success was reached. I think it's a workable methodology but it was too ambitious for the time frame.

---

## How to Run My Agent

### Prerequisites
```bash
node 20+
```

### Installation
```bash
cd agent/
npm install
```

### Execution
```bash
npm run start
```

### Configuration
.env - needs API key

---

## Lessons Learned

I should have been better prepared before beginning.
---

## Additional Notes

As a philospher by background, I've done a lot of deep thinking on AI, and can bring outside-the-box thinking and creative techniques in AI to bear on my 17 years of craftsmanship as a professional programmer.
import { TestFile } from "./types";

export const SYSTEM_PROMPT = `
You are an expert software architect performing semantic reverse-engineering.

You must infer program behavior ONLY from:
- Provided source code
- Provided tests

Rules:
- If a claim is directly supported by code or tests, label it PROVEN.
- If a claim is inferred, label it INFERRED.
- Never invent undocumented behavior.
- Prioritize tests over implementation if they conflict.
- Your goal is not refactoring, but reconstructability.
`;
export function universalPromptFromTests(testFile: TestFile): string {
  return `
You are an expert software architect performing behavioral reverse-engineering.

You are given ONLY the behavioral tests for a system.
No source code is available in this phase.

EPISTEMIC RULES:
- Treat tests as authoritative descriptions of behavior.
- Do not speculate beyond what tests enforce.
- If behavior is not exercised by tests, mark it UNKNOWN.
- Distinguish REQUIRED behavior from OPTIONAL behavior.

TASK: UNIVERSAL ANALYSIS (TESTS-ONLY)

Infer the system's global behavior.

Produce:
1. System purpose (what problem this system solves)
2. Domain entities and their properties
3. Supported operations and workflows
4. Input/output behavior enforced by tests
5. Global invariants (what must always be true)
6. Error cases and edge conditions
7. Explicit UNKNOWNs (behaviors not covered by tests)

## OUTPUT STRUCTURE (IMPORTANT)

Your output MUST be a list of blocks.
Each block MUST declare its Kind explicitly.

Allowed Kinds:
- Model        (persistent or conceptual data structures)
- Operation    (externally observable behaviors)
- Invariant    (conditions that must always hold)
- EdgeCase     (boundary or failure behaviors)
- Unknown      (behavior suggested but not provable)
- Narrative    (anything important that doesn't fit elsewhere)

---

## BLOCK FORMATS

### Model
- Kind: Model
- Name: <ModelName>
- Fields:
  - <fieldName>: <type> — <short description>

### Operation
- Kind: Operation
- Name: <BehaviorName>
- Description: <1–2 sentences>
- Behaviors:
  - <observable behavior>
  - <observable behavior>

### Invariant
- Kind: Invariant
- Name: <InvariantName>
- Statements:
  - <condition that must always be true>

### EdgeCase
- Kind: EdgeCase
- Name: <EdgeCaseName>
- Scenarios:
  - <boundary condition>
  - <failure mode>

### Unknown
- Kind: Unknown
- Name: <AreaOfUncertainty>
- Notes:
  - <what is unclear and why>

### Narrative
- Kind: Narrative
- Name: <NarrativeTitle>
- Content:
  - brief statements

---

## RULES

- Prefer clarity over brevity.
- Use plain English.
- Avoid Markdown formatting inside names and types.
- Types should be simple (string, number, boolean, array, object).
- If a field or behavior is inferred but uncertain, place it in Unknown.
- If multiple behaviors share a name, split them.

---

## GOAL

Produce a report that a human can read
AND a machine can parse without guessing.

---

Here is the complete source code bundle:


Behavioral Tests:
${testFile.content}
`;
}
export function individualPromptFromCode(code: string): string {
  return `You are performing a CODE-FIRST INDIVIDUAL ANALYSIS.

You are given ONLY the source code of a system.
You are NOT given tests, documentation, or a system specification.

Your task is to identify INDIVIDUAL responsibility units
strictly from what the code actually implements.

NOTE:
- The codebase uses AngularJS.
- Treat AngularJS-specific constructs (modules, controllers, services,
  dependency injection, $scope) as observable mechanisms, not predefined roles.
- Do NOT infer intended behavior or missing features.
- Describe only what the code actually does.
- Split loosely related behaviors into separate units.
- Treat unused or dead code as its own unit.

DEFINITION:
An Individual unit is the smallest coherent responsibility
that can be described independently and is directly evidenced in code.

OUTPUT REQUIREMENTS:
- Produce a JSON array of objects.
- Each object represents a single Individual unit.
- Each object must have the following fields:

{
  id: number;                   // sequential identifier
  name: string;                 // behavioral name of the unit
  unitType?: 'component' | 'directive' | 'pipe' | 'service' | 'controller' | 'other'; 
                                // Angular unit type or generic
  selector?: string;            // Angular selector for components/directives
  bindings?: {                  // Angular-style input/output bindings
    inputs?: string[];
    outputs?: string[];
  };
  lifecycleHooks?: string[];    // e.g., ngOnInit, ngOnDestroy
  templateHints?: string;       // minimal HTML or DOM notes
  parent?: string;              // optional parent component/container
  childComponents?: string[];   // components nested inside this unit

  evidence: string;             // exact code locations/functions/lines
  responsibility: string;       // concise description of what the unit does
  inputs: string[];             // actual inputs or data read
  outputs: string[];            // return values or mutated data
  stateUsage: string[];         // globals, locals, or shared state accessed
  sideEffects: string[];        // e.g., DOM, console, network, timers
}

- Include all observable behaviors; do NOT omit any field.
- For fields with no content, use an empty array or empty string.
- Explicitly note overlapping or duplicate responsibilities as part of "responsibility" or "evidence".
- Include dead, unused, or unreachable code as separate units.
- If any behavior is weakly evidenced, mark it clearly in the "evidence" field.

TASKS:
1. Identify all Individual responsibility units.
2. For each unit, produce a JSON object as above.
3. Output a single JSON array containing all units; no extra text or Markdown.

Here is the complete source code bundle:
${code}
`;
}
export function individualPromptForPerlCode(code: string): string {
  return `
You are performing a CODE-FIRST INDIVIDUAL ANALYSIS
of a LEGACY PERL CODEBASE.

You are given ONLY the Perl source code.
You are NOT given tests, documentation, comments, or specifications.

Your task is to identify INDIVIDUAL responsibility units
strictly from what the code actually implements.

---

## CORE PRINCIPLES (STRICT)

- Describe ONLY behavior that is directly evidenced in code.
- Do NOT infer intent, design goals, or missing features.
- Do NOT modernize, refactor, or normalize behavior.
- Assume the code may be:
  - procedural
  - partially object-oriented
  - dependent on global variables
  - dependent on filesystem, environment variables, or external processes
- Treat commented-out, unreachable, or unused code as REAL and ANALYZABLE.

---

## PERL-SPECIFIC INTERPRETATION RULES

- An Individual unit may be:
  - a subroutine
  - a package
  - a block of top-level procedural code
  - a BEGIN / END block
  - an implicit behavior expressed through side effects
- Subroutines are NOT assumed to be pure or reusable.
- Repeated data structures (hashes, arrays, scalars) imply domain concepts.
- Global variables (our, use vars, package vars) are FIRST-CLASS state.
- Behavior expressed through:
  - print / say
  - die / warn
  - system / exec / backticks
  - file reads or writes
  - environment variables
  - exit codes
  is considered externally observable output.
- If a unit does multiple unrelated things, SPLIT IT.

---

## DEFINITION: INDIVIDUAL UNIT

An Individual unit is the SMALLEST coherent responsibility
that can be independently described and is directly evidenced in code.

“Coherent” means:
- one primary responsibility
- one observable behavioral outcome
- one conceptual role in the system

---

## OUTPUT REQUIREMENTS (MANDATORY)

- Output MUST be a single JSON array.
- Each element represents exactly ONE Individual unit.
- Do NOT include explanations, prose, or Markdown outside JSON.

Each object MUST have ALL of the following fields:

{
  id: number;                     // sequential identifier starting at 1
  name: string;                   // concise behavioral name (what it DOES)
  unitType: 'subroutine' | 'package' | 'procedural' | 'initializer' | 'cleanup' | 'unknown';

  evidence: string;               // exact file names, sub names, line ranges, or code excerpts
  responsibility: string;         // plain-English description of what the unit does

  inputs: string[];               // arguments, globals, files, env vars read
  outputs: string[];              // return values, printed output, files written, exit codes
  stateUsage: string[];           // globals, package vars, lexical vars captured
  sideEffects: string[];          // filesystem, network, process, STDOUT/ERR, time, signals

  dependencies: string[];         // modules used, subs called, external commands
  errorHandling: string[];        // die, warn, return undef, exit, implicit failures

  notes: string[];                // ambiguities, weak evidence, or unusual patterns
}

---

## ADDITIONAL RULES

- Every field must be present.
- If a field has no content, use an empty array or empty string.
- If behavior is weakly evidenced, explicitly say so in "notes".
- If two units partially overlap, do NOT merge them—note the overlap.
- Dead, unused, or unreachable code MUST be emitted as its own unit.
- Do NOT invent names, inputs, or outputs not directly supported by code.

---

## GOAL

Produce a lossless, mechanically parsable decomposition
of what this Perl codebase ACTUALLY DOES.

This output must be suitable for:
- behavioral reconstruction
- test synthesis
- cross-language reimplementation

---

Here is the complete Perl source code bundle:

${code}
`;
}
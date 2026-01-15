Kind: Narrative
Name: SystemPurpose
Content:
  - The system is a command‑line log analyzer that reads a single log file (e.g., app.log) and produces summary reports.
  - Reports include error and warning counts, overall statistics, IP address frequencies, user login summaries, and request timing statistics.
  - Output can be rendered as human‑readable text (default) or as JSON when the `--json` flag is supplied.
  - Multiple report types can be requested simultaneously; the tool concatenates the requested sections in the output.
  - The script exits with status 0 on successful processing and a non‑zero status on fatal errors (missing file, missing required arguments, etc.).

---
Kind: Model
Name: LogFile
Fields:
  - path: string — filesystem location of the log file to be analyzed.
  - exists: boolean — true if the file can be opened for reading.

---
Kind: Model
Name: ErrorSummary
Fields:
  - total: number — total number of error entries found in the log.
  - details: array<object> — optional per‑error breakdown (exact structure not exercised by tests).

---
Kind: Model
Name: WarningSummary
Fields:
  - total: number — total number of warning entries found in the log.
  - details: array<object> — optional per‑warning breakdown.

---
Kind: Model
Name: Statistics
Fields:
  - lines: number — total number of log lines processed.
  - errors: number — count of error entries.
  - warnings: number — count of warning entries.
  - other_metrics: object — any additional numeric metrics reported (structure not exercised by tests).

---
Kind: Model
Name: IPAnalysis
Fields:
  - ip_counts: object — mapping from IP address string to occurrence count (e.g., {"192.0.2.1": 42}).

---
Kind: Model
Name: UserAnalysis
Fields:
  - user_counts: object — mapping from username string to login count (e.g., {"alice": 5}).

---
Kind: Model
Name: TimingAnalysis
Fields:
  - min_ms: number — minimum request time in milliseconds.
  - max_ms: number — maximum request time in milliseconds.
  - avg_ms: number — average request time in milliseconds.
  - distribution: object — optional histogram or percentile data (not exercised by tests).

---
Kind: Operation
Name: RunWithFlag
Description: Execute the analyzer with a single reporting flag (e.g., --errors) and optionally --json.
Behaviors:
  - When the flag is provided without --json, the script writes a plain‑text report that must match the corresponding golden *.txt file exactly.
  - When the flag is provided together with --json, the script writes a JSON document that, when parsed, must be deep‑equal to the corresponding golden *.json data.
  - In both cases the process exits with status 0.

---
Kind: Operation
Name: RunDefault
Description: Execute the analyzer with a valid log file but no reporting flags.
Behaviors:
  - The script produces the same output as the `--stats` flag in plain‑text form.
  - The process exits with status 0.

---
Kind: Operation
Name: RunMultipleFlags
Description: Execute the analyzer with two or more reporting flags in a single invocation.
Behaviors:
  - The output contains a distinct section for each requested flag (e.g., an error section and a warning section).
  - The presence of each section can be detected by searching for case‑insensitive keywords such as "error summary" or "warning summary".
  - The overall exit status is 0.
  - When all six flags are supplied, the output length is greater than 100 characters (as verified by the test).

---
Kind: Operation
Name: RunMissingFile
Description: Execute the analyzer with a path that does not exist.
Behaviors:
  - The process exits with a non‑zero status code.
  - No requirement is placed on stdout/stderr content beyond the non‑zero exit.

---
Kind: Operation
Name: RunNoArguments
Description: Execute the analyzer without providing a log‑file argument.
Behaviors:
  - The process exits with a non‑zero status code.
  - The tool writes usage information or an error message to stdout or stderr (the test only checks that some output is produced and contains the word “usage” case‑insensitively).

---
Kind: Invariant
Name: SuccessExitCode
Statements:
  - If the script successfully reads the supplied log file and processes at least one reporting flag (or defaults to stats), it must exit with code 0.
  - If the script cannot read the log file or is invoked without required arguments, it must exit with a non‑zero code.

---
Kind: Invariant
Name: TextOutputExactMatch
Statements:
  - For each reporting flag (`--errors`, `--warnings`, `--stats`, `--ips`, `--users`, `--times`) when `--json` is **not** supplied, the text written to stdout must be byte‑for‑byte identical to the corresponding golden *.txt file located in `expected-outputs`.

---
Kind: Invariant
Name: JsonOutputValidity
Statements:
  - When a reporting flag is combined with `--json`, the stdout must be valid JSON (parsable by `json.loads`).
  - The parsed JSON object must be deep‑equal to the JSON content of the corresponding golden *.json file.

---
Kind: Invariant
Name: DefaultShowsStats
Statements:
  - Invoking the script with a valid log file and **no** reporting flags must produce exactly the same stdout as `--stats` (text mode).

---
Kind: Invariant
Name: SectionPresenceWhenMultipleFlags
Statements:
  - If multiple reporting flags are supplied, the stdout must contain at least one recognizable identifier for each requested report (e.g., the words “Error Summary” or “errors” for `--errors`, “Warning Summary” or “warnings” for `--warnings`).

---
Kind: EdgeCase
Name: MissingLogFile
Scenarios:
  - Input path does not exist → script exits with non‑zero status; output content not specified.

---
Kind: EdgeCase
Name: NoArgumentsProvided
Scenarios:
  - Script invoked without any positional arguments → script exits with non‑zero status and emits usage or error text on stdout or stderr.

---
Kind: Unknown
Name: UnrecognizedCommandLineOptions
Notes:
  - The behavior when flags other than the six documented ones are supplied is not exercised by the tests.

---
Kind: Unknown
Name: OutputOrderingWhenMultipleFlags
Notes:
  - Tests only check that each requested section appears; the relative order of sections is not verified.

---
Kind: Unknown
Name: JsonOutputWithMultipleFlags
Notes:
  - No test combines `--json` with more than one reporting flag; it is unclear whether the script should emit a single combined JSON document, multiple JSON documents, or reject the combination.

---
Kind: Unknown
Name: DuplicateFlagHandling
Notes:
  - The effect of specifying the same flag multiple times (e.g., `--errors --errors`) is not covered.

---
Kind: Unknown
Name: PerformanceAndScalability
Notes:
  - No tests address processing time, memory usage, or limits on log file size.

---
Kind: Unknown
Name: ExactStructureOfJsonObjects
Notes:
  - While the tests compare full JSON objects to golden files, the internal schema (field names, nesting) is only known insofar as it matches those golden files; the model fields listed above are inferred but not verified against the golden content.
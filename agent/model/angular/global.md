**System Purpose**  
A data‑service that stores a collection of employee records and provides read‑only query capabilities – filtering, searching, sorting, exporting and statistical summarisation – while guaranteeing that the original data set is never mutated.

---

### Model
- Kind: Model
- Name: Employee
- Fields:
  - id: number — Unique identifier
  - firstName: string — Given name
  - lastName: string — Family name
  - email: string — Contact e‑mail
  - department: string — Business unit (e.g., Engineering, Sales, Marketing, HR, Finance)
  - role: string — Job title or function
  - location: string — Physical office location (e.g., Columbus)
  - hireDate: string — ISO‑8601 date string representing hire date
  - salary: number — Annual compensation
  - active: boolean — Employment status (`true` = currently employed)
  - skills: array — List of skill strings

### Model
- Kind: Model
- Name: ExportEmployee
- Fields:
  - id: number — Same as Employee.id
  - name: string — Concatenation `"FirstName LastName"` (capitalized first letter)
  - email: string — Employee.email
  - department: string — Employee.department
  - role: string — Employee.role
  - location: string — Employee.location

### Model
- Kind: Model
- Name: Statistics
- Fields:
  - total: number — Total number of employee records
  - active: number — Count where `active === true`
  - inactive: number — Count where `active === false`
  - byDepartment: object — Mapping from department name to employee count (e.g., `Engineering: 8`)

---

### Operation
- Kind: Operation
- Name: FilterByDepartment
- Description: Returns a new array containing only employees whose `department` matches the supplied value (case‑sensitive as tested).
- Behaviors:
  - Result length equals the number of employees in that department (e.g., 8 for Engineering, 4 for Sales).
  - Every returned employee has `department` equal to the requested value.
  - Original employee objects are unchanged (identity equality with source where ids match).

### Operation
- Kind: Operation
- Name: FilterByLocation
- Description: Returns employees whose `location` matches the supplied value.
- Behaviors:
  - Result length matches expected count (e.g., 6 for Columbus).
  - All returned employees have `location` equal to the requested value.
  - No mutation of source data.

### Operation
- Kind: Operation
- Name: FilterActive
- Description: Returns only employees with `active === true`.
- Behaviors:
  - Result length equals the count of active employees (18 in test data).
  - Every returned employee has `active` true.
  - Source data unchanged.

### Operation
- Kind: Operation
- Name: ComplexFilter
- Description: Combines multiple predicates (department, location, active) into a single filter.
- Behaviors:
  - Returned array satisfies **all** supplied predicates (e.g., Engineering + Columbus + Active).
  - No ordering guarantee unless an explicit sort is also requested.

### Operation
- Kind: Operation
- Name: ComplexFilterWithSort
- Description: Filters by department and active status, then sorts the result by `lastName` ascending.
- Behaviors:
  - All items match the filter criteria (`department === 'Sales' && active === true`).
  - Result array is ordered such that `lastName` (case‑insensitive) is non‑decreasing.

### Operation
- Kind: Operation
- Name: Search
- Description: Performs a case‑insensitive substring search across `firstName`, `lastName`, `email`, `role`, and `department`.
- Behaviors:
  - Query `"smith"` returns exactly one employee whose `lastName` is `"Smith"`.
  - Query `"engineer"` returns at least one employee where either `role` or `department` contains the word “engineer” (case‑insensitive).
  - Search is case‑insensitive for all target fields.

### Operation
- Kind: Operation
- Name: SortByLastNameAsc
- Description: Returns all employees sorted by `lastName` in ascending alphabetical order (case‑insensitive).
- Behaviors:
  - Result length is the full dataset size (20).
  - Ordering condition: for every adjacent pair, `prev.lastName.lowercase() <= curr.lastName.lowercase()`.

### Operation
- Kind: Operation
- Name: SortByLastNameDesc
- Description: Returns all employees sorted by `lastName` descending.
- Behaviors:
  - Same length as full dataset.
  - Ordering condition: `prev.lastName.lowercase() >= curr.lastName.lowercase()`.

### Operation
- Kind: Operation
- Name: SortBySalaryAsc
- Description: Returns all employees sorted by numeric `salary` ascending.
- Behaviors:
  - Full dataset length.
  - For each adjacent pair, `prev.salary <= curr.salary`.

### Operation
- Kind: Operation
- Name: SortByHireDateAsc
- Description: Returns all employees sorted by `hireDate` (ISO string) ascending.
- Behaviors:
  - Full dataset length.
  - For each adjacent pair, `new Date(prev.hireDate) <= new Date(curr.hireDate)`.

### Operation
- Kind: Operation
- Name: ExportSelected
- Description: Transforms a supplied list of employees into the `ExportEmployee` shape.
- Behaviors:
  - Output array length equals number of supplied employees (example test uses 3).
  - Each exported object contains exactly the required fields (`id`, `name`, `email`, `department`, `role`, `location`).
  - `name` matches the regex `^[A-Z][a-z]+ [A-Z][a-z]+$` (capitalized first and last names, single space).

### Operation
- Kind: Operation
- Name: ComputeStatistics
- Description: Produces a `Statistics` object summarising the employee collection.
- Behaviors:
  - `total` equals the total number of employees (20).
  - `active` and `inactive` counts sum to `total`.
  - `byDepartment` maps each known department to its employee count (e.g., Engineering = 8, Sales = 4, Marketing = 3, HR = 2, Finance = 2).
  - Sum of all department counts equals `total`.

---

### Invariant
- Kind: Invariant
- Name: EmployeeSchemaInvariant
- Statements:
  - Every employee object must have the fields listed in the `Employee` model.
  - Field types must match the specifications (e.g., `id` number, `active` boolean, `skills` array).
  - No operation mutates the original employee objects (identity and value equality preserved).

### Invariant
- Kind: Invariant
- Name: StatisticsConsistency
- Statements:
  - `total = active + inactive`.
  - `total = Σ(byDepartment[dept])` over all departments present.

---

### EdgeCase
- Kind: EdgeCase
- Name: EmptyResultFilters
- Scenarios:
  - Filtering by a department, location, or combination that does not exist should return an empty array (behavior not exercised but logically required for a filter function).
  - No mutation of source data when result set is empty.

### EdgeCase
- Kind: EdgeCase
- Name: SearchNoMatch
- Scenarios:
  - Searching for a term that matches no employee should return an empty array (not covered by tests).

### EdgeCase
- Kind: EdgeCase
- Name: SortStabilityAndTies
- Scenarios:
  - When two employees share the same sort key (e.g., identical `lastName`), the relative order is unspecified (tests do not verify stability).

### EdgeCase
- Kind: EdgeCase
- Name: InvalidInputParameters
- Scenarios:
  - Passing non‑string values for filter criteria, or non‑boolean for `active`, is not exercised; expected behavior is UNKNOWN.

### EdgeCase
- Kind: EdgeCase
- Name: ExportMissingFields
- Scenarios:
  - Exporting a list that contains malformed employee objects (missing required fields) is not covered; behavior UNKNOWN.

---

### Unknown
- Kind: Unknown
- Name: MutationDuring Complex Operations
- Notes:
  - Tests verify that simple filtering does not mutate original data, but they do not explicitly confirm immutability for combined filters, searches, or sorts. The system *should* preserve immutability, but this is not proven by the test suite.

### Unknown
- Kind: Unknown
- Name: Pagination / Limiting
- Notes:
  - No tests address limiting result size, paging, or streaming; behavior unspecified.

### Unknown
- Kind: Unknown
- Name: Case Sensitivity of Filter Criteria
- Notes:
  - Filters are exercised with exact‑case values (e.g., `'Engineering'`). Whether the filter is case‑insensitive is not asserted.

### Unknown
- Kind: Unknown
- Name: Error Handling for Missing Files / Load Failures
- Notes:
  - `loadGoldenFile` is assumed to succeed; failure modes are not tested.

### Unknown
- Kind: Unknown
- Name: Permissions / Authentication
- Notes:
  - No tests involve access control; behavior unknown.

---

### Narrative
- Kind: Narrative
- Name: Overall System Guarantees
- Content:
  - The service is read‑only: all exposed operations return new collections or transformed objects without altering the source dataset.
  - All operations are deterministic with respect to the supplied static dataset used in the golden files.
  - The golden files constitute the authoritative expected output; the candidate implementation must produce byte‑wise equal results for the exercised scenarios.
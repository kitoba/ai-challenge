# Challenge 1: AngularJS → Modern Angular

## Prerequisites

### Required Tools

- **Node.js 20+ (22.x LTS recommended)** - For running Angular
- **npm 9+** - Package manager (comes with Node.js)

### Installation

**Quick setup (from repo root):**
```bash
./scripts/setup-prerequisites.sh
```

This installs all required tools for all 3 challenges.

**Manual installation:** See `../../docs/PREREQUISITES.md`

---

## Overview

Modernize a legacy AngularJS 1.6.9 Employee Directory application to **Angular 18+** (Angular 20 recommended) with TypeScript, standalone components, and modern best practices.

**Recommended:** Use Angular 20 (current stable, released May 2025) for latest features (zoneless change detection, stable signals, linkedSignal). Angular 18+ is acceptable.

## The Legacy Application

**Location:** `legacy-app/`
**Tech Stack:**
- AngularJS 1.6.9
- Vanilla JavaScript (no TypeScript)
- ~2,500 lines of code
- Controllers, Services, Directives, Custom Filters

**Features:**
- Employee list view with cards
- Search across name, email, role
- Filter by department, location, active status
- Sort by various fields (ascending/descending)
- Multi-select employees
- Export selected employees

## Running the Legacy App

```bash
cd legacy-app
npm install
npm run serve
# Open http://localhost:8080
```

The app will load test data from `../test-inputs/employees.json` (20 employees).

## Problematic Patterns (Intentional)

This legacy app contains realistic anti-patterns your agent must handle:

### 1. **$scope instead of controllerAs**
```javascript
employeeApp.controller('MainController', function($scope) {
    $scope.employees = []; // Should use this.employees with controllerAs
});
```

### 2. **Callback hell**
Nested promises/callbacks that should use async/await or RxJS

### 3. **Deprecated $http methods**
```javascript
$http.get(url).success(...).error(...) // Should use .then()/.catch()
```

### 4. **Global scope pollution**
```javascript
window.APP_CONFIG = {...}
window.employeeCache = null;
```

### 5. **Manual DOM manipulation**
```javascript
element[0].querySelector('.employee-card').classList.add('highlight');
```

### 6. **Inline templates**
Directive templates as strings instead of separate files

### 7. **No TypeScript**
No type safety, interfaces, or compile-time checks

### 8. **Mixed patterns**
Inconsistent service patterns, unnecessary watchers, imperative code

## Your Goal: Modern Angular 18+

Transform this to:
- ✅ **Standalone components** (no NgModules)
- ✅ **TypeScript** with proper types and interfaces
- ✅ **RxJS** for reactive programming
- ✅ **Signals** for state management (stable in Angular 20)
- ✅ **OnPush change detection**
- ✅ **Dependency injection** with proper services
- ✅ **Modern HttpClient** (not deprecated $http)
- ✅ **Component templates** (not inline strings)
- ✅ **Pipes** instead of custom filters
- ✅ **No manual DOM manipulation**

## Expected Output Structure

Your modernized code should be in `/output/angularjs-to-angular/` with structure like:

```
output/angularjs-to-angular/
├── src/
│   ├── app/
│   │   ├── components/
│   │   │   ├── employee-card/
│   │   │   └── employee-list/
│   │   ├── services/
│   │   │   ├── employee.service.ts
│   │   │   └── filter.service.ts
│   │   ├── models/
│   │   │   └── employee.model.ts
│   │   ├── pipes/
│   │   └── app.component.ts
│   ├── main.ts
│   └── index.html
├── angular.json
├── package.json
└── tsconfig.json
```

## Test Data

**Input:** `test-inputs/employees.json` - 20 employee records

Your app must:
1. Load this JSON file
2. Implement all the same features
3. Produce identical outputs for same operations

## Golden Outputs (What We Test Against)

We run the legacy app with known operations and capture outputs:

1. **Filter by department "Engineering"** → `expected-outputs/filter-engineering.json`
2. **Sort by lastName ascending** → `expected-outputs/sort-lastname-asc.json`
3. **Search for "smith"** → `expected-outputs/search-smith.json`
4. **Complex: Engineering + Columbus + Active** → `expected-outputs/complex-filter.json`
5. **Export selected employees** → `expected-outputs/export-sample.json`

## Running Tests

Once you've modernized the app:

```bash
cd tests
npm install
npm test
```

Our test suite includes:

### Behavioral Tests (tests/e2e/)
- Load employees and verify count
- Filter by department matches golden output
- Sort operations match legacy behavior
- Search results match exactly
- Selection and export work correctly

### Unit Tests (tests/unit/)
- Services use proper TypeScript types
- Components use OnPush change detection
- HTTP calls return Observables (not callbacks)
- No global variables
- Proper dependency injection

## Scoring Criteria

Your solution will be scored on:

| Criteria | Points | How We Test |
|----------|--------|-------------|
| **Functionality** | 30 | Do behavioral tests pass? |
| **Code Quality** | 25 | Is it idiomatic Angular 18+? |
| **TypeScript** | 15 | Proper types, interfaces, no `any`? |
| **Architecture** | 15 | Standalone components, services, clean structure? |
| **Modern Patterns** | 15 | Signals, RxJS, OnPush, no DOM manipulation? |

**Pass threshold:** 75/100 points

## Tips

1. **Start with data model:** Define `Employee` interface first
2. **Service layer:** Create `EmployeeService` with HttpClient
3. **Build incrementally:** Get basic list working, then add features
4. **Use Angular CLI:** Generate components/services properly
5. **Test locally:** Run our tests frequently
6. **No manual DOM:** Use Angular's reactive primitives

## Common Pitfalls

❌ Using `any` everywhere instead of proper types
❌ Creating NgModules (use standalone: true)
❌ Not using RxJS for async operations
❌ Manual DOM manipulation with ElementRef
❌ Not implementing all features from legacy app
❌ Ignoring the test data format

## Questions?

No questions allowed - figuring it out is part of the challenge! But the legacy app is fully functional, so you can run it to understand the behavior.

---

**Good luck! This tests your ability to modernize real legacy code, not just generate new apps.**

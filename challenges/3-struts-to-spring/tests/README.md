# Struts → Spring Boot Test Suite

## Overview

Tests validate that your Spring Boot application:
1. Implements all required REST endpoints
2. Returns JSON matching golden files
3. Uses modern Spring Boot 3.x patterns
4. Employs Java 21 features

## Running Tests

```bash
mvn test
```

## Test Structure

```
tests/
├── integration/     # API response tests
└── unit/            # Pattern validation tests
```

## Golden Files

Expected API responses in `expected-outputs/`:
- `list-all.json` - GET /api/products
- `get-one.json` - GET /api/products/1
- `create.json` - POST /api/products
- `update.json` - PUT /api/products/1
- `search.json` - GET /api/products/search?name=Widget

## Scoring

- Functional tests: 30 pts
- Spring patterns: 25 pts
- Java 21 features: 15 pts
- REST conventions: 15 pts
- Code quality: 15 pts

Total: 100 pts (75+ to pass)

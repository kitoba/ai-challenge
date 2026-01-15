# Challenge 3: Struts → Spring Boot

## Overview

Modernize a legacy Apache Struts 1.x inventory management API to **Spring Boot 3.4+** (3.5 recommended) with REST controllers, JPA, and modern **Java 17+** patterns (Java 21 LTS recommended).

**This is the most complex of the three challenges** - it tests enterprise Java modernization skills.

---

## Prerequisites

### Required Tools

- **Java 17+ (Java 21 LTS recommended)** - For running Spring Boot 3.x
- **Maven 3.8+** - For building Java projects

### Installation

**Quick setup (from repo root):**
```bash
./scripts/setup-prerequisites.sh
```

This installs all required tools for all 3 challenges.

**Manual installation:** See `../../docs/PREREQUISITES.md`

---

## ⚠️ CRITICAL: Java Version Requirements

- **Legacy Struts app:** Built with Java 8 (you don't need to run it, just analyze the code)
- **Your Spring Boot app:** **Requires Java 17 minimum** (Java 21 LTS recommended)
- **Why:** Spring Boot 3.x does NOT work with Java 8!

If you try to use Java 8 for your Spring Boot app, it will fail immediately. Use Java 17+ or 21 LTS.

---

## The Legacy Application

**Location:** `legacy-app/` - **Real, runnable Struts 1.x application!**

**Tech Stack:**
- Apache Struts 1.3.10 (final Struts 1.x release, 2008)
- Java 8
- Maven build system
- XML-based configuration (web.xml + struts-config.xml)
- Action classes with execute() methods
- ActionForms for data binding
- JSP views for JSON output (anti-pattern!)
- Singleton DAO with HashMap storage (in-memory)
- Manual JSON construction using org.json library

**Features:**
- Product management API (CRUD operations)
- Search products by name
- Filter products by category
- Sort products by various fields
- JSON responses via query parameter (?format=json)

**Running the app:**
```bash
cd legacy-app
mvn clean package
mvn jetty:run
```

Runs on: **http://localhost:8080/products**

See `legacy-app/README.md` for full API documentation and curl examples.

## Problematic Patterns (Intentional)

### 1. **XML Configuration Hell**
```xml
<struts-config>
  <form-beans>
    <form-bean name="productForm" type="com.nationwide.inventory.forms.ProductForm"/>
  </form-beans>
  <action-mappings>
    <action path="/products/list" type="com.nationwide.inventory.actions.ListProductsAction">
      <forward name="success" path="/WEB-INF/json.jsp"/>
    </action>
  </action-mappings>
</struts-config>
```

### 2. **Action Classes with execute()**
```java
public class ListProductsAction extends Action {
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                                HttpServletRequest request, HttpServletResponse response) {
        // Problem: Business logic in action class
    }
}
```

### 3. **FormBeans for Data Binding**
```java
public class ProductForm extends ActionForm {
    private String name;
    private String price;
    // String-based everything, no type safety
}
```

### 4. **Manual JSON Construction**
```java
String json = "{\"id\":" + id + ",\"name\":\"" + name + "\"}";
```

### 5. **Old Java Patterns**
- Java 8 syntax (no records, no pattern matching)
- Verbose getters/setters
- No Optional
- No streams (or basic streams)

### 6. **Session Management**
Old-style HttpSession usage instead of Spring Security

## Your Goal: Modern Spring Boot 3.x

Transform to:
- ✅ **@RestController** with @RequestMapping
- ✅ **@RequestBody/@ResponseBody** for JSON
- ✅ **Spring Data JPA** (with H2 in-memory for simplicity)
- ✅ **Java 17+** features - records, pattern matching (Java 21 LTS recommended)
- ✅ **@SpringBootApplication** main class
- ✅ **application.yml** configuration (not XML)
- ✅ **ResponseEntity<T>** for HTTP responses
- ✅ **Proper REST conventions** (GET/POST/PUT/DELETE)
- ✅ **@Valid** with Bean Validation
- ✅ **Exception handling** with @ControllerAdvice

## Expected Output Structure

```
output/struts-to-spring/
├── src/main/java/com/nationwide/inventory/
│   ├── InventoryApplication.java          # @SpringBootApplication
│   ├── controller/
│   │   └── ProductController.java         # @RestController
│   ├── model/
│   │   ├── Product.java                   # @Entity or record
│   │   └── ProductRequest.java            # DTOs
│   ├── repository/
│   │   └── ProductRepository.java         # JpaRepository
│   ├── service/
│   │   └── ProductService.java            # Business logic
│   └── exception/
│       └── GlobalExceptionHandler.java    # @ControllerAdvice
├── src/main/resources/
│   ├── application.yml
│   └── data.sql                           # Initial data
├── src/test/java/
│   └── ...                                # Tests
├── pom.xml
└── README.md
```

## API Endpoints to Implement

| Method | Path | Description | Request Body | Response |
|--------|------|-------------|--------------|----------|
| GET | `/api/products` | List all products | - | Product[] |
| GET | `/api/products/{id}` | Get product by ID | - | Product |
| POST | `/api/products` | Create product | ProductRequest | Product |
| PUT | `/api/products/{id}` | Update product | ProductRequest | Product |
| DELETE | `/api/products/{id}` | Delete product | - | 204 No Content |
| GET | `/api/products/search?name={name}` | Search by name | - | Product[] |

## Test Data

**Input:** `test-data/products.json` - 20 sample products

## Golden Outputs (Sample Test Cases)

The `expected-outputs/` directory contains **sample test cases** that demonstrate the expected API behavior:

1. **List all** → `expected-outputs/list-all.json`
2. **Get product 1** → `expected-outputs/get-product-1.json`
3. **Search "widget"** → `expected-outputs/search-widget.json`
4. **Empty search** → `expected-outputs/search-empty.json`
5. **Filter Tools** → `expected-outputs/filter-tools.json`
6. **Sort by name** → `expected-outputs/sort-name.json`
7. *(Additional samples provided)*

Your Spring Boot app must return **identical JSON** for equivalent requests.

### ⚠️ IMPORTANT: Hidden Test Cases

**During evaluation, additional test cases will be used that are NOT provided in this repository.**

These hidden tests will verify:
- ✅ **Error handling:** How does your API respond to invalid inputs?
  - Non-existent product IDs (should return 404)
  - Invalid query parameters (should return 400)
  - Malformed requests

- ✅ **Edge cases:** Can your implementation handle:
  - Empty result sets
  - Special characters in search queries
  - Boundary conditions

- ✅ **HTTP semantics:** Does your API use proper status codes?
  - 200 OK for successful GET
  - 201 Created for successful POST
  - 404 Not Found for missing resources
  - 400 Bad Request for invalid input
  - 500 Internal Server Error should be avoided

**Recommendation:** Don't just match the provided golden outputs. Build a robust, production-quality API that handles all reasonable scenarios and edge cases properly.

## Running Tests

```bash
cd tests
mvn test
```

Test suites:
- **Integration tests:** HTTP API responses match golden files
- **Unit tests:** Modern Spring/Java patterns used

## Scoring Criteria

| Criteria | Points |
|----------|--------|
| **Functionality** | 30 pts - API responses match |
| **Spring Boot Patterns** | 25 pts - @RestController, JPA, etc. |
| **Java 17+ Features** | 15 pts - Records, pattern matching (21 recommended) |
| **REST Conventions** | 15 pts - Proper HTTP methods/status codes |
| **Code Quality** | 15 pts - Clean, maintainable |

**Pass threshold:** 75/100

## Tips

1. Start with Product entity and repository
2. Build service layer with business logic
3. Create REST controller
4. Add validation and exception handling
5. Test with Postman/curl
6. Run our tests

## Common Pitfalls

❌ Still using XML configuration
❌ Action classes instead of @RestController
❌ Manual JSON serialization
❌ Old Java 8 patterns
❌ No proper HTTP status codes
❌ Missing validation

---

**This is the final challenge. Complete all three to prove you can build general-purpose modernization agents!**

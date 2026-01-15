# Legacy Product Management System - Struts 1.x

This is a **real, runnable Struts 1.x application** demonstrating legacy patterns that need modernization.

## Anti-Patterns Included

This legacy app intentionally demonstrates problematic patterns common in old Struts applications:

### Architecture Anti-Patterns
- **XML-heavy configuration** (struts-config.xml, web.xml)
- **No service layer** - Actions call DAO directly
- **No dependency injection** - Singleton pattern for DAO
- **Action classes with execute() methods** - Tight coupling to Struts framework
- **FormBeans for data binding** - String-based form fields

### Code Anti-Patterns
- **Manual JSON construction** - Using ancient org.json library
- **Manual type conversion** - String to int/double with poor error handling
- **No validation framework** - Manual validation in Action classes
- **Session-based state** - Implicit session management
- **Global mutable state** - Singleton DAO with HashMap storage
- **No transactions** - In-memory storage with no ACID guarantees

### Modern Replacements Needed
- Struts Actions → Spring `@RestController`
- ActionForm → Spring `@RequestBody` with DTOs
- execute() method → HTTP method annotations (`@GetMapping`, `@PostMapping`)
- struts-config.xml → Spring Boot auto-configuration
- Manual JSON → Jackson automatic serialization
- Singleton DAO → Spring JPA repositories with `@Repository`
- In-memory HashMap → JPA with database

## Prerequisites

- Java 8+ (Java 8 specifically for true legacy feel)
- Maven 3.6+

## Building the Application

```bash
cd legacy-app
mvn clean package
```

This creates `target/product-management.war`

## Running the Application

### Option 1: Using Maven Jetty Plugin (Easiest)

```bash
mvn jetty:run
```

Application runs on: **http://localhost:8080/products**

### Option 2: Using Maven Tomcat7 Plugin

```bash
mvn tomcat7:run
```

Application runs on: **http://localhost:8080/products**

### Option 3: Deploy WAR to External Tomcat

1. Build: `mvn clean package`
2. Copy `target/product-management.war` to Tomcat's `webapps/` directory
3. Start Tomcat
4. Access: **http://localhost:8080/product-management**

## API Endpoints

All endpoints support JSON output by adding `?format=json` parameter.

### List All Products
```bash
curl "http://localhost:8080/products/listProducts.do?format=json"
```

**Response:**
```json
[
  {"id":1,"name":"Widget Pro","category":"Tools","price":29.99,"stock":150},
  {"id":2,"name":"Gadget Max","category":"Electronics","price":199.99,"stock":45},
  ...
]
```

### View Single Product
```bash
curl "http://localhost:8080/products/viewProduct.do?id=1&format=json"
```

**Response:**
```json
{"id":1,"name":"Widget Pro","category":"Tools","price":29.99,"stock":150}
```

### Search Products
```bash
curl "http://localhost:8080/products/searchProducts.do?query=widget&format=json"
```

**Response:**
```json
[
  {"id":1,"name":"Widget Pro","category":"Tools","price":29.99,"stock":150},
  {"id":5,"name":"Basic Widget","category":"Tools","price":9.99,"stock":200}
]
```

### Filter by Category
```bash
curl "http://localhost:8080/products/filterByCategory.do?category=Tools&format=json"
```

**Response:**
```json
[
  {"id":1,"name":"Widget Pro","category":"Tools","price":29.99,"stock":150},
  {"id":3,"name":"Tool Kit","category":"Tools","price":89.99,"stock":80},
  {"id":5,"name":"Basic Widget","category":"Tools","price":9.99,"stock":200}
]
```

### Add Product (POST)
```bash
curl -X POST "http://localhost:8080/products/addProduct.do?format=json" \
  -d "name=New Product" \
  -d "category=Tools" \
  -d "price=49.99" \
  -d "stock=100"
```

**Response:**
```json
{"id":6,"name":"New Product","category":"Tools","price":49.99,"stock":100}
```

### Update Product (POST)
```bash
curl -X POST "http://localhost:8080/products/updateProduct.do?format=json" \
  -d "id=6" \
  -d "name=Updated Product" \
  -d "category=Tools" \
  -d "price=59.99" \
  -d "stock=75"
```

**Response:**
```json
{"id":6,"name":"Updated Product","category":"Tools","price":59.99,"stock":75}
```

### Delete Product
```bash
curl "http://localhost:8080/products/deleteProduct.do?id=6&format=json"
```

**Response:**
```json
{"success":true,"message":"Product deleted"}
```

### Sort Products
```bash
# Sort by name
curl "http://localhost:8080/products/listProducts.do?format=json&sortBy=name"

# Sort by price (ascending)
curl "http://localhost:8080/products/listProducts.do?format=json&sortBy=price"

# Sort by price (descending)
curl "http://localhost:8080/products/listProducts.do?format=json&sortBy=price_desc"

# Sort by category
curl "http://localhost:8080/products/listProducts.do?format=json&sortBy=category"
```

## Test Data

The application initializes with 5 products (matching `test-data/products.json`):

| ID | Name | Category | Price | Stock |
|----|------|----------|-------|-------|
| 1 | Widget Pro | Tools | $29.99 | 150 |
| 2 | Gadget Max | Electronics | $199.99 | 45 |
| 3 | Tool Kit | Tools | $89.99 | 80 |
| 4 | Smart Device | Electronics | $299.99 | 30 |
| 5 | Basic Widget | Tools | $9.99 | 200 |

## Your Modernization Task

Build an AI agent that:

1. **Analyzes** this Struts 1.x codebase
2. **Understands** the business logic and API contracts
3. **Generates** a modern Spring Boot 3.x application that:
   - Uses `@RestController` with REST conventions
   - Implements JPA with proper entity models
   - Uses Java 21+ features (records, pattern matching)
   - Follows modern best practices (dependency injection, validation)
   - Returns **identical JSON outputs** for the same requests

## What Makes This Realistic

This mirrors real-world Struts 1.x applications at Nationwide:

✅ **XML-heavy configuration** - Typical of early 2000s Java apps
✅ **Action/FormBean pattern** - Standard Struts 1.x architecture
✅ **Manual JSON handling** - Common before Jackson became standard
✅ **Tight framework coupling** - Hard to test, hard to maintain
✅ **No modern patterns** - No DI, no REST, no modern Java features

Your AI agent must handle these real migration challenges!

## Troubleshooting

### Port Already in Use
```bash
# Change port in pom.xml or:
mvn jetty:run -Djetty.port=9090
```

### Build Errors
```bash
# Clean and rebuild
mvn clean install -U
```

### JSON Not Displaying
Make sure to add `?format=json` to the URL. Without it, Struts will try to render JSP views (which are minimal in this app).

## License

Created for Nationwide AI Modernization Challenge

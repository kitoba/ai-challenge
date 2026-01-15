# Struts 1.x Legacy Application - Setup Guide

## Overview

This is a **real, runnable Struts 1.x application** built with Maven. It demonstrates authentic legacy patterns found in enterprise Java applications from the early 2000s.

## Requirements

- **Java 8+** (Java 8 recommended for authentic legacy experience)
- **Maven 3.6+**

## Quick Start

```bash
cd legacy-app
mvn clean package
mvn jetty:run
```

Application runs on: **http://localhost:8080/products**

## Verification

Once running, test the API:

```bash
# List all products
curl "http://localhost:8080/products/listProducts.do?format=json"

# Should return JSON array with 5 products
```

See `README.md` for full API documentation and all available endpoints.

## Project Structure

```
legacy-app/
├── pom.xml                              # Maven build configuration
├── src/
│   ├── main/
│   │   ├── java/com/nationwide/legacy/
│   │   │   ├── actions/                 # Struts Action classes
│   │   │   │   ├── ListProductsAction.java
│   │   │   │   ├── ViewProductAction.java
│   │   │   │   ├── AddProductAction.java
│   │   │   │   ├── UpdateProductAction.java
│   │   │   │   ├── DeleteProductAction.java
│   │   │   │   ├── SearchProductsAction.java
│   │   │   │   └── FilterByCategoryAction.java
│   │   │   ├── forms/                   # Struts ActionForms
│   │   │   │   ├── ProductForm.java
│   │   │   │   └── SearchForm.java
│   │   │   ├── model/                   # Domain objects
│   │   │   │   └── Product.java
│   │   │   ├── dao/                     # Data Access Objects
│   │   │   │   └── ProductDAO.java      # Singleton with in-memory storage
│   │   │   └── util/                    # Utilities
│   │   │       └── JsonHelper.java      # Manual JSON construction
│   │   ├── resources/
│   │   │   └── ApplicationResources.properties
│   │   └── webapp/
│   │       ├── WEB-INF/
│   │       │   ├── web.xml              # Servlet configuration
│   │       │   ├── struts-config.xml    # Struts routing/config
│   │       │   └── jsp/
│   │       │       ├── json.jsp         # JSON output view
│   │       │       └── error.jsp        # Error page
│   │       └── index.jsp                # Welcome page
```

## Anti-Patterns Demonstrated

See `README.md` for full list of anti-patterns and how they should be modernized.

## Generating Golden Outputs

After starting the app, run:

```bash
cd ..
./generate-golden-outputs.sh
```

This creates `expected-outputs/*.json` files for testing.

## Troubleshooting

### Maven Not Found
```bash
# Install Maven
sudo apt-get install maven  # Ubuntu/Debian
brew install maven          # macOS
```

### Java Not Found
```bash
# Install Java 8
sudo apt-get install openjdk-8-jdk  # Ubuntu/Debian
brew install openjdk@8               # macOS
```

### Port 8080 Already in Use
```bash
# Use different port
mvn jetty:run -Djetty.port=9090
```

### Build Fails
```bash
# Update dependencies
mvn clean install -U
```

## What Makes This Authentic

This Struts 1.x app mirrors real-world legacy code at Nationwide:

✅ Uses Struts 1.3.10 (final Struts 1.x release from 2008)
✅ XML-heavy configuration (struts-config.xml, web.xml)
✅ Action/ActionForm pattern with execute() methods
✅ Manual JSON handling with ancient org.json library
✅ Singleton DAO pattern with in-memory HashMap
✅ No dependency injection or modern frameworks
✅ Java 8 source/target compatibility
✅ Manual type conversion and validation
✅ Session-based state management

Your AI agent must understand and modernize all of these patterns!

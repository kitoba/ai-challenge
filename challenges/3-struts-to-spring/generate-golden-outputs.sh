#!/bin/bash

# Generate golden output files for Struts→Spring Boot challenge
# This script starts the legacy Struts app and captures JSON responses

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEGACY_APP="$SCRIPT_DIR/legacy-app"
OUTPUT_DIR="$SCRIPT_DIR/expected-outputs"

echo "🏗️  Building legacy Struts application..."
cd "$LEGACY_APP"
mvn clean package -DskipTests

echo "🚀 Starting Struts app on port 8080..."
mvn jetty:run &
APP_PID=$!

# Wait for app to start
echo "⏳ Waiting for app to be ready..."
sleep 15

# Check if app is running
if ! curl -s http://localhost:8080/products/ > /dev/null 2>&1; then
    echo "❌ App failed to start"
    kill $APP_PID 2>/dev/null || true
    exit 1
fi

echo "✅ App is running, generating golden outputs..."
mkdir -p "$OUTPUT_DIR"

BASE_URL="http://localhost:8080/products"

# 1. List all products
echo "📄 Generating list-all.json..."
curl -s "${BASE_URL}/listProducts.do?format=json" | python3 -m json.tool > "$OUTPUT_DIR/list-all.json"

# 2. View single product (ID 1)
echo "📄 Generating get-product-1.json..."
curl -s "${BASE_URL}/viewProduct.do?id=1&format=json" | python3 -m json.tool > "$OUTPUT_DIR/get-product-1.json"

# 3. Search for "widget"
echo "📄 Generating search-widget.json..."
curl -s "${BASE_URL}/searchProducts.do?query=widget&format=json" | python3 -m json.tool > "$OUTPUT_DIR/search-widget.json"

# 4. Filter by category: Tools
echo "📄 Generating filter-tools.json..."
curl -s "${BASE_URL}/filterByCategory.do?category=Tools&format=json" | python3 -m json.tool > "$OUTPUT_DIR/filter-tools.json"

# 5. Filter by category: Electronics
echo "📄 Generating filter-electronics.json..."
curl -s "${BASE_URL}/filterByCategory.do?category=Electronics&format=json" | python3 -m json.tool > "$OUTPUT_DIR/filter-electronics.json"

# 6. Sort by name
echo "📄 Generating sort-name.json..."
curl -s "${BASE_URL}/listProducts.do?format=json&sortBy=name" | python3 -m json.tool > "$OUTPUT_DIR/sort-name.json"

# 7. Sort by price (ascending)
echo "📄 Generating sort-price-asc.json..."
curl -s "${BASE_URL}/listProducts.do?format=json&sortBy=price" | python3 -m json.tool > "$OUTPUT_DIR/sort-price-asc.json"

# 8. Sort by price (descending)
echo "📄 Generating sort-price-desc.json..."
curl -s "${BASE_URL}/listProducts.do?format=json&sortBy=price_desc" | python3 -m json.tool > "$OUTPUT_DIR/sort-price-desc.json"

# 9. View product 2
echo "📄 Generating get-product-2.json..."
curl -s "${BASE_URL}/viewProduct.do?id=2&format=json" | python3 -m json.tool > "$OUTPUT_DIR/get-product-2.json"

# 10. Search for "device"
echo "📄 Generating search-device.json..."
curl -s "${BASE_URL}/searchProducts.do?query=device&format=json" | python3 -m json.tool > "$OUTPUT_DIR/search-device.json"

# 11. Empty search (should return all)
echo "📄 Generating search-empty.json..."
curl -s "${BASE_URL}/searchProducts.do?query=&format=json" | python3 -m json.tool > "$OUTPUT_DIR/search-empty.json"

# 12. Sort by category
echo "📄 Generating sort-category.json..."
curl -s "${BASE_URL}/listProducts.do?format=json&sortBy=category" | python3 -m json.tool > "$OUTPUT_DIR/sort-category.json"

echo "🛑 Stopping Struts app..."
kill $APP_PID 2>/dev/null || true
sleep 2
kill -9 $APP_PID 2>/dev/null || true

echo "✅ Golden outputs generated in: $OUTPUT_DIR"
echo "📊 Total files created: $(ls -1 "$OUTPUT_DIR" | wc -l)"

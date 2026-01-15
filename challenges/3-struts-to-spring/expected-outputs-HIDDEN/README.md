# Hidden Test Cases - Spring Boot Challenge

## Test Files in This Directory

### From Original Set (Hidden from Candidates)
1. `get-product-2.json` - GET /api/products/2 → 200
2. `search-device.json` - GET /api/products/search?q=device → 200
3. `filter-electronics.json` - GET /api/products/filter?category=Electronics → 200
4. `sort-price-asc.json` - GET /api/products/sort?field=price&order=asc → 200
5. `sort-price-desc.json` - GET /api/products/sort?field=price&order=desc → 200

### New Edge Cases (Error Handling)
6. `get-product-999-404.json` - GET /api/products/999 → **404 Not Found**
7. `get-product-invalid-400.json` - GET /api/products/abc → **400 Bad Request**

## HTTP Status Code Tests (No Golden File Needed)

These tests only check the HTTP status code:

- GET /api/products/999 → Must return 404
- GET /api/products/abc → Must return 400
- GET /api/nonexistent → Must return 404
- GET /api/products?limit=-1 → Should return 400 (optional)

## Verification Logic

```bash
# Test hidden golden outputs
for file in expected-outputs-HIDDEN/*.json; do
    endpoint=$(extract_endpoint_from_filename "$file")
    expected_status=$(extract_status_from_filename "$file")

    actual=$(curl -s -w "%{http_code}" http://localhost:8080$endpoint)

    if [ "$actual_status" != "$expected_status" ]; then
        echo "✗ HIDDEN TEST FAILED: $endpoint"
        ((HIDDEN_ERRORS++))
    fi
done
```

## Scoring

- PUBLIC tests (7): Worth 60% of functionality score
- HIDDEN tests (7): Worth 40% of functionality score

Total: 14 test cases

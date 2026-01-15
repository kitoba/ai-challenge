package com.nationwide.legacy.util;

import com.nationwide.legacy.model.Product;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

/**
 * Utility for JSON serialization - Legacy pattern
 *
 * ANTI-PATTERNS:
 * - Manual JSON construction (not using Jackson/Gson)
 * - Using ancient org.json library
 * - No error handling
 * - Static methods (no testability)
 * - No proper serialization framework
 */
public class JsonHelper {

    // Problem: Static utility class (hard to test, no DI)
    private JsonHelper() {
    }

    /**
     * Convert single product to JSON string
     */
    public static String productToJson(Product product) throws JSONException {
        // Problem: Manual JSON construction
        JSONObject json = new JSONObject();
        json.put("id", product.getId());
        json.put("name", product.getName());
        json.put("category", product.getCategory());
        json.put("price", product.getPrice());
        json.put("stock", product.getStock());
        return json.toString();
    }

    /**
     * Convert list of products to JSON array string
     */
    public static String productsToJson(List<Product> products) throws JSONException {
        // Problem: Manual iteration and JSON array building
        JSONArray jsonArray = new JSONArray();
        for (Product product : products) {
            JSONObject json = new JSONObject();
            json.put("id", product.getId());
            json.put("name", product.getName());
            json.put("category", product.getCategory());
            json.put("price", product.getPrice());
            json.put("stock", product.getStock());
            jsonArray.put(json);
        }
        return jsonArray.toString();
    }

    /**
     * Convert product to JSON with pretty printing (for debugging)
     */
    public static String productToJsonPretty(Product product) throws JSONException {
        JSONObject json = new JSONObject();
        json.put("id", product.getId());
        json.put("name", product.getName());
        json.put("category", product.getCategory());
        json.put("price", product.getPrice());
        json.put("stock", product.getStock());
        // Problem: toString(2) for indentation - not standard
        return json.toString(2);
    }
}

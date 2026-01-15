package com.nationwide.legacy.dao;

import com.nationwide.legacy.model.Product;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Data Access Object for Products - Legacy pattern
 *
 * ANTI-PATTERNS:
 * - Singleton pattern (global state)
 * - In-memory storage (no database)
 * - No transactions
 * - No connection pooling
 * - Manual synchronization
 * - No proper error handling
 */
public class ProductDAO {
    // Problem: Singleton instance (global mutable state)
    private static ProductDAO instance;

    // Problem: In-memory storage using HashMap
    private Map<Integer, Product> products;
    private int nextId;

    // Problem: Private constructor for singleton
    private ProductDAO() {
        products = new HashMap<>();
        nextId = 1;
        initializeData();
    }

    // Problem: Singleton getInstance() pattern
    public static synchronized ProductDAO getInstance() {
        if (instance == null) {
            instance = new ProductDAO();
        }
        return instance;
    }

    // Initialize with test data (from products.json)
    private void initializeData() {
        addProduct(new Product(1, "Widget Pro", "Tools", 29.99, 150));
        addProduct(new Product(2, "Gadget Max", "Electronics", 199.99, 45));
        addProduct(new Product(3, "Tool Kit", "Tools", 89.99, 80));
        addProduct(new Product(4, "Smart Device", "Electronics", 299.99, 30));
        addProduct(new Product(5, "Basic Widget", "Tools", 9.99, 200));
        nextId = 6; // Next available ID
    }

    // Problem: Manual synchronization instead of using concurrent collections
    public synchronized List<Product> getAllProducts() {
        // Problem: Returning mutable list
        return new ArrayList<>(products.values());
    }

    public synchronized Product getProductById(int id) {
        return products.get(id);
    }

    public synchronized Product addProduct(Product product) {
        if (product.getId() == 0) {
            product.setId(nextId++);
        } else {
            nextId = Math.max(nextId, product.getId() + 1);
        }
        products.put(product.getId(), product);
        return product;
    }

    public synchronized Product updateProduct(Product product) {
        // Problem: No validation if product exists
        if (products.containsKey(product.getId())) {
            products.put(product.getId(), product);
            return product;
        }
        return null;
    }

    public synchronized boolean deleteProduct(int id) {
        return products.remove(id) != null;
    }

    public synchronized List<Product> searchProducts(String query) {
        // Problem: Case-sensitive search, inefficient linear scan
        if (query == null || query.trim().isEmpty()) {
            return getAllProducts();
        }

        String lowerQuery = query.toLowerCase();
        return products.values().stream()
                .filter(p -> p.getName().toLowerCase().contains(lowerQuery))
                .collect(Collectors.toList());
    }

    public synchronized List<Product> getProductsByCategory(String category) {
        // Problem: Case-sensitive filtering
        if (category == null || category.trim().isEmpty()) {
            return getAllProducts();
        }

        return products.values().stream()
                .filter(p -> category.equals(p.getCategory()))
                .collect(Collectors.toList());
    }

    // Problem: Exposing count method that duplicates logic
    public synchronized int getProductCount() {
        return products.size();
    }

    // Problem: Method to reset data (testing only, but exposed publicly)
    public synchronized void resetData() {
        products.clear();
        nextId = 1;
        initializeData();
    }
}

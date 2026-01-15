package com.nationwide.legacy.model;

import java.io.Serializable;

/**
 * Product domain object - Legacy Struts 1.x pattern
 *
 * ANTI-PATTERNS:
 * - No encapsulation (public fields)
 * - No validation
 * - Mutable state
 * - No builder pattern
 * - No equals/hashCode
 */
public class Product implements Serializable {
    private static final long serialVersionUID = 1L;

    // Problem: Public fields (no encapsulation)
    public int id;
    public String name;
    public String category;
    public double price;
    public int stock;

    // Problem: No-arg constructor required by Struts
    public Product() {
    }

    // Problem: All-args constructor but no validation
    public Product(int id, String name, String category, double price, int stock) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.stock = stock;
    }

    // Simple getters and setters (required by Struts FormBean binding)
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }

    // Problem: toString() instead of proper JSON serialization
    @Override
    public String toString() {
        return "Product{id=" + id + ", name='" + name + "', category='" + category +
               "', price=" + price + ", stock=" + stock + "}";
    }
}

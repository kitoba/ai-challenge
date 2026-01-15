package com.nationwide.legacy.forms;

import org.apache.struts.action.ActionForm;

/**
 * Struts 1.x ActionForm for Product
 *
 * ANTI-PATTERNS:
 * - Extends ActionForm (tight coupling to Struts)
 * - String-based form fields (type conversion done manually)
 * - No validation logic
 * - Mutable state
 */
public class ProductForm extends ActionForm {
    private static final long serialVersionUID = 1L;

    // Problem: Everything is String (manual conversion needed)
    private String id;
    private String name;
    private String category;
    private String price;
    private String stock;

    public ProductForm() {
    }

    // Getters and setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
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

    public String getPrice() {
        return price;
    }

    public void setPrice(String price) {
        this.price = price;
    }

    public String getStock() {
        return stock;
    }

    public void setStock(String stock) {
        this.stock = stock;
    }

    // Problem: Manual reset() method (Struts requirement)
    @Override
    public void reset(org.apache.struts.action.ActionMapping mapping,
                      javax.servlet.http.HttpServletRequest request) {
        this.id = null;
        this.name = null;
        this.category = null;
        this.price = null;
        this.stock = null;
    }
}

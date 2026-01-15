package com.nationwide.legacy.actions;

import com.nationwide.legacy.dao.ProductDAO;
import com.nationwide.legacy.forms.ProductForm;
import com.nationwide.legacy.model.Product;
import com.nationwide.legacy.util.JsonHelper;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Add a new product
 */
public class AddProductAction extends Action {

    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                                  HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        ProductForm productForm = (ProductForm) form;

        // Problem: Manual validation in Action class
        if (productForm.getName() == null || productForm.getName().trim().isEmpty()) {
            request.setAttribute("errorMessage", "Product name is required");
            return mapping.findForward("error");
        }

        // Problem: Manual type conversion with poor error handling
        try {
            Product product = new Product();
            product.setName(productForm.getName());
            product.setCategory(productForm.getCategory());
            product.setPrice(Double.parseDouble(productForm.getPrice()));
            product.setStock(Integer.parseInt(productForm.getStock()));

            ProductDAO dao = ProductDAO.getInstance();
            Product savedProduct = dao.addProduct(product);

            String format = request.getParameter("format");
            if ("json".equals(format)) {
                String json = JsonHelper.productToJson(savedProduct);
                request.setAttribute("jsonResponse", json);
                return mapping.findForward("json");
            }

            return mapping.findForward("success");

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid number format: " + e.getMessage());
            return mapping.findForward("error");
        }
    }
}

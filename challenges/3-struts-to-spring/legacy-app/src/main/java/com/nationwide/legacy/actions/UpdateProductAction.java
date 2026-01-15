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
 * Update an existing product
 */
public class UpdateProductAction extends Action {

    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                                  HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        ProductForm productForm = (ProductForm) form;

        try {
            int id = Integer.parseInt(productForm.getId());

            Product product = new Product();
            product.setId(id);
            product.setName(productForm.getName());
            product.setCategory(productForm.getCategory());
            product.setPrice(Double.parseDouble(productForm.getPrice()));
            product.setStock(Integer.parseInt(productForm.getStock()));

            ProductDAO dao = ProductDAO.getInstance();
            Product updatedProduct = dao.updateProduct(product);

            if (updatedProduct == null) {
                request.setAttribute("errorMessage", "Product not found: " + id);
                return mapping.findForward("error");
            }

            String format = request.getParameter("format");
            if ("json".equals(format)) {
                String json = JsonHelper.productToJson(updatedProduct);
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

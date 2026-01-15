package com.nationwide.legacy.actions;

import com.nationwide.legacy.dao.ProductDAO;
import com.nationwide.legacy.model.Product;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Display the update product form
 */
public class UpdateProductFormAction extends Action {

    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                                  HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            request.setAttribute("errorMessage", "Product ID is required");
            return mapping.findForward("error");
        }

        try {
            int id = Integer.parseInt(idStr);

            ProductDAO dao = ProductDAO.getInstance();
            Product product = dao.getProductById(id);

            if (product == null) {
                request.setAttribute("errorMessage", "Product not found: " + id);
                return mapping.findForward("error");
            }

            request.setAttribute("product", product);
            request.setAttribute("formAction", "updateProduct.do");
            request.setAttribute("formTitle", "Update Product");

            return mapping.findForward("success");

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid product ID");
            return mapping.findForward("error");
        }
    }
}

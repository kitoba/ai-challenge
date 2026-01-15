package com.nationwide.legacy.actions;

import com.nationwide.legacy.dao.ProductDAO;
import com.nationwide.legacy.model.Product;
import com.nationwide.legacy.util.JsonHelper;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * View a single product by ID
 */
public class ViewProductAction extends Action {

    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                                  HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        // Problem: Manual parameter extraction and parsing
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            request.setAttribute("errorMessage", "Product ID is required");
            return mapping.findForward("error");
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid product ID");
            return mapping.findForward("error");
        }

        ProductDAO dao = ProductDAO.getInstance();
        Product product = dao.getProductById(id);

        if (product == null) {
            request.setAttribute("errorMessage", "Product not found: " + id);
            return mapping.findForward("error");
        }

        String format = request.getParameter("format");
        if ("json".equals(format)) {
            String json = JsonHelper.productToJson(product);
            request.setAttribute("jsonResponse", json);
            return mapping.findForward("json");
        }

        request.setAttribute("product", product);
        return mapping.findForward("success");
    }
}

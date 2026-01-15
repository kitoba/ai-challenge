package com.nationwide.legacy.actions;

import com.nationwide.legacy.dao.ProductDAO;
import com.nationwide.legacy.util.JsonHelper;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Delete a product
 */
public class DeleteProductAction extends Action {

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
            boolean deleted = dao.deleteProduct(id);

            if (!deleted) {
                request.setAttribute("errorMessage", "Product not found: " + id);
                return mapping.findForward("error");
            }

            String format = request.getParameter("format");
            if ("json".equals(format)) {
                // Problem: Manual JSON construction for success message
                String json = "{\"success\": true, \"message\": \"Product deleted\"}";
                request.setAttribute("jsonResponse", json);
                return mapping.findForward("json");
            }

            return mapping.findForward("success");

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid product ID");
            return mapping.findForward("error");
        }
    }
}

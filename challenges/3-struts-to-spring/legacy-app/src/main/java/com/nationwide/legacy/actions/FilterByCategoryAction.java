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
import java.util.List;

/**
 * Filter products by category
 */
public class FilterByCategoryAction extends Action {

    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                                  HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String category = request.getParameter("category");

        ProductDAO dao = ProductDAO.getInstance();
        List<Product> products = dao.getProductsByCategory(category);

        String format = request.getParameter("format");
        if ("json".equals(format)) {
            String json = JsonHelper.productsToJson(products);
            request.setAttribute("jsonResponse", json);
            return mapping.findForward("json");
        }

        request.setAttribute("products", products);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("productCount", products.size());

        return mapping.findForward("success");
    }
}

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
 * Struts Action to list all products
 *
 * ANTI-PATTERNS:
 * - Extends Action (tight coupling to Struts)
 * - Manual request/response handling
 * - Mixing business logic with presentation logic
 * - No dependency injection
 * - Direct DAO access (no service layer)
 */
public class ListProductsAction extends Action {

    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                                  HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        // Problem: Direct DAO access (no service layer, no DI)
        ProductDAO dao = ProductDAO.getInstance();
        List<Product> products = dao.getAllProducts();

        // Problem: Manual sorting based on request parameter
        String sortBy = request.getParameter("sortBy");
        if (sortBy != null && !sortBy.isEmpty()) {
            products = sortProducts(products, sortBy);
        }

        // Check if JSON response is requested
        String format = request.getParameter("format");
        if ("json".equals(format)) {
            // Problem: Manual JSON construction
            String json = JsonHelper.productsToJson(products);
            request.setAttribute("jsonResponse", json);
            return mapping.findForward("json");
        }

        // Problem: Setting attributes directly on request
        request.setAttribute("products", products);
        request.setAttribute("productCount", products.size());

        return mapping.findForward("success");
    }

    // Problem: Business logic in Action class
    private List<Product> sortProducts(List<Product> products, String sortBy) {
        // Problem: Manual sorting without proper comparator abstraction
        products.sort((p1, p2) -> {
            switch (sortBy) {
                case "name":
                    return p1.getName().compareToIgnoreCase(p2.getName());
                case "price":
                    return Double.compare(p1.getPrice(), p2.getPrice());
                case "price_desc":
                    return Double.compare(p2.getPrice(), p1.getPrice());
                case "category":
                    return p1.getCategory().compareToIgnoreCase(p2.getCategory());
                case "stock":
                    return Integer.compare(p1.getStock(), p2.getStock());
                default:
                    return Integer.compare(p1.getId(), p2.getId());
            }
        });
        return products;
    }
}

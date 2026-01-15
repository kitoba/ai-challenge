package com.nationwide.legacy.actions;

import com.nationwide.legacy.dao.ProductDAO;
import com.nationwide.legacy.forms.SearchForm;
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
 * Search products by name
 */
public class SearchProductsAction extends Action {

    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                                  HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        SearchForm searchForm = (SearchForm) form;
        String query = searchForm.getQuery();

        ProductDAO dao = ProductDAO.getInstance();
        List<Product> products = dao.searchProducts(query);

        String format = request.getParameter("format");
        if ("json".equals(format)) {
            String json = JsonHelper.productsToJson(products);
            request.setAttribute("jsonResponse", json);
            return mapping.findForward("json");
        }

        request.setAttribute("products", products);
        request.setAttribute("searchQuery", query);
        request.setAttribute("productCount", products.size());

        return mapping.findForward("success");
    }
}

package com.nationwide.legacy.actions;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Display the add product form
 */
public class AddProductFormAction extends Action {

    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                                  HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        request.setAttribute("formAction", "addProduct.do");
        request.setAttribute("formTitle", "Add New Product");
        return mapping.findForward("success");
    }
}

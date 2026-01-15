package com.nationwide.legacy.forms;

import org.apache.struts.action.ActionForm;

/**
 * Struts 1.x ActionForm for search functionality
 */
public class SearchForm extends ActionForm {
    private static final long serialVersionUID = 1L;

    private String query;
    private String category;

    public SearchForm() {
    }

    public String getQuery() {
        return query;
    }

    public void setQuery(String query) {
        this.query = query;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    @Override
    public void reset(org.apache.struts.action.ActionMapping mapping,
                      javax.servlet.http.HttpServletRequest request) {
        this.query = null;
        this.category = null;
    }
}

<%@ page contentType="application/json; charset=UTF-8" %><%
    // Problem: JSP for JSON output (should use REST controller)
    String jsonResponse = (String) request.getAttribute("jsonResponse");
    if (jsonResponse != null) {
        out.print(jsonResponse);
    }
%>
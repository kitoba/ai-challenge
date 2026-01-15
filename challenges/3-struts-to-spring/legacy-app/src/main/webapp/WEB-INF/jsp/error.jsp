<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<!DOCTYPE html>
<html>
<head>
    <title>Error - Product Management</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .error { color: red; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Error</h1>
    <p class="error"><%= request.getAttribute("errorMessage") %></p>
    <p><a href="listProducts.do">Back to Product List</a></p>
</body>
</html>

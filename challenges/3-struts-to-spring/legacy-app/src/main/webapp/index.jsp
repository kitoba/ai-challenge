<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Legacy Product Management System</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .info-box { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        h1 { color: #333; }
        ul { line-height: 1.8; }
        .endpoint { font-family: monospace; background: #e8e8e8; padding: 2px 6px; }
    </style>
</head>
<body>
    <h1>Legacy Product Management System</h1>
    <div class="info-box">
        <h2>Struts 1.x Application</h2>
        <p>This is a legacy Struts 1.x application for the AI Modernization Challenge.</p>

        <h3>Available Endpoints:</h3>
        <ul>
            <li><strong>List All Products (JSON):</strong> <span class="endpoint">GET /products/listProducts.do?format=json</span></li>
            <li><strong>View Product (JSON):</strong> <span class="endpoint">GET /products/viewProduct.do?id=1&format=json</span></li>
            <li><strong>Search Products (JSON):</strong> <span class="endpoint">GET /products/searchProducts.do?query=widget&format=json</span></li>
            <li><strong>Filter by Category (JSON):</strong> <span class="endpoint">GET /products/filterByCategory.do?category=Tools&format=json</span></li>
            <li><strong>Add Product (POST):</strong> <span class="endpoint">POST /products/addProduct.do?format=json</span></li>
            <li><strong>Update Product (POST):</strong> <span class="endpoint">POST /products/updateProduct.do?format=json</span></li>
            <li><strong>Delete Product:</strong> <span class="endpoint">GET /products/deleteProduct.do?id=1&format=json</span></li>
        </ul>

        <h3>Quick Links:</h3>
        <ul>
            <li><a href="listProducts.do?format=json">List All Products (JSON)</a></li>
            <li><a href="viewProduct.do?id=1&format=json">View Product #1 (JSON)</a></li>
            <li><a href="searchProducts.do?query=widget&format=json">Search "widget" (JSON)</a></li>
            <li><a href="filterByCategory.do?category=Tools&format=json">Filter Tools (JSON)</a></li>
        </ul>
    </div>
</body>
</html>

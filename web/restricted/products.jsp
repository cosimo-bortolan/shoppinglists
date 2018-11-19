<%@page import="db.entities.User"%>
<%@page import="java.util.List"%>
<%@page import="db.entities.Product"%>
<%@page import="db.exceptions.DAOFactoryException"%>
<%@page import="db.factories.DAOFactory"%>
<%@page import="db.factories.DAOFactory"%>
<%@page import="db.daos.ProductDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%! private ProductDAO productDao;

    @Override
    public void init() throws ServletException {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory for user storage system");
        }
        try {
            productDao = daoFactory.getDAO(ProductDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao factory for product storage system", ex);
        }
    }

%>
<%
    User user = (User) request.getSession().getAttribute("user");
    List<Product> products;
    if (user.isAdmin()) {
        products = productDao.getPublic();
    } else {
        products = productDao.getByUser(user.getId());
    }
    pageContext.setAttribute("products", products);
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>My products</title>
        <%@include file="../include/generalMeta.jsp" %>

    </head>
    <body>
        <div id="containerPage">
            <div id="header">
                <div class="jumbotron">
                    <div class="container text-center">
                        <h1>I miei prodotti</h1>      
                    </div>
                </div>
                <%@include file="../include/navigationBar.jsp" %>
            </div>
            <div id="body">
                <c:forEach items="${products}" var="product">
                    Nome: <a href="${pageContext.response.encodeURL(contextPath.concat("restricted/ProductServlet?res=1&productId=").concat(product.id))}">${product.name}</a><br>
                    Note: ${product.notes}<br>
                    <c:forEach items="${categories}" var="category">
                        <c:if test="${category.id==product.productCategoryId}">${category.name}</c:if>
                    </c:forEach><br>
                    <img height="50px" src="${contextPath}images/productCategories/icons/${product.logoPath}"><br>
                    <br>
                </c:forEach>
                <br>
                <a href="${pageContext.response.encodeURL(contextPath.concat("restricted/productForm.jsp"))}">Aggiungi prodotto</a>
            </div>
            <%@include file="../include/footer.jsp" %>
        </div>
    </body>
</html>

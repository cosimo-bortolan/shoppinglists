<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Product Category</title>
        <%@include file="include/generalMeta.jsp" %>
        <script>
            function deleteProductCategory(id) {
                var xhttp = new XMLHttpRequest();
                xhttp.onreadystatechange = function () {
                    if (this.readyState === 4 && this.status === 204) {
                        window.location.href = "${pageContext.response.encodeURL(contextPath.concat("restricted/categories.jsp"))}";
                    } else if (this.readyState === 4 && this.status === 400) {
                        alert("Bad request!");
                    } else if (this.readyState === 4 && this.status === 403) {
                        alert("You are not allowed to delete the productCategory!");
                    } else if (this.readyState === 4 && this.status === 500) {
                        alert("Impossible to delete the productCategory!");
                    }
                };
                var url = "${pageContext.response.encodeURL(contextPath.concat("restricted/ProductCategoryServlet"))}";
                xhttp.open("DELETE", url + "?productCategoryId=" + id, true);
                xhttp.send();
            }
        </script>
    </head>
    <body>
        <div id="containerPage">
            <div id="header">
                <div class="jumbotron myBackground" >
                    <div class="container text-center">
                        <h1>${productCategory.name}</h1>      
                    </div>
                </div>
                <%@include file="include/navigationBar.jsp" %>
            </div>
            <div id="body">
                <a href="${pageContext.response.encodeURL(contextPath.concat("restricted/categories.jsp"))}">Product Categories</a>
                <div class="myContainer row">    
                    <div class="col-12">
                        <div class="panel panel-default-custom">
                            <div class="panel-heading-custom">
                                <img src="${contextPath}images/productCategories/${productCategory.logoPath}" alt="Logo" class="small-logo" height="40px" width="40px"> 
                                ${productCategory.name}
                            </div>
                            <div>
                                ${productCategory.description}
                            </div>
                            <br>
                            <a href="${pageContext.response.encodeURL(contextPath.concat("restricted/ProductCategoryServlet?res=2&productCategoryId=").concat(productCategory.id))}">Modifica</a>
                            <span onclick="deleteProductCategory(${productCategory.id})">Elimina</span><br>
                            <div class="panel-footer-custom"></div>

                        </div>
                    </div>
                    <c:forEach items="${products}" var="product">
                        <div class="col-12 col-sm-6 col-md-4 col-lg-3">
                            <c:choose>
                                <c:when test="${product.isReserved()}">
                                    <div class="panel panel-default-custom" onclick="window.location.href = '${pageContext.response.encodeURL(contextPath.concat("restricted/ProductServlet?res=1&productId=").concat(product.id))}'">
                                    </c:when>
                                    <c:when test="${not product.isReserved()}">
                                        <div class="panel panel-default-custom" onclick="window.location.href = '${pageContext.response.encodeURL(contextPath.concat("ProductPublic?productId=").concat(product.id))}'">
                                        </c:when>
                                    </c:choose>
                                    <div class="panel-heading-custom" >
                                        <img src="${contextPath}images/productCategories/icons/${product.logoPath}" alt="Logo" class="small-logo" height="40px" width="40px"> 
                                        ${product.name}
                                    </div>
                                    <c:forEach items="${product.photoPath}" var="photo" end="0">
                                        <img class="item fit-image img-responsive" src="${contextPath}images/products/${photo}"  alt="${product.name}">
                                    </c:forEach>
                                    <div class="panel-footer-custom"></div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
                <%@include file="include/footer.jsp" %>
            </div>
    </body>
</html>

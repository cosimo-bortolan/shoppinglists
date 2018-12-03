<%@page import="db.entities.User"%>
<%@page import="db.entities.Product"%>
<%@page import="db.daos.ProductDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="db.entities.ShoppingList"%>
<%@page import="db.exceptions.DAOFactoryException"%>
<%@page import="db.factories.DAOFactory"%>
<%@page import="db.daos.ShoppingListDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%! private ShoppingListDAO shoppingListDao;

    @Override
    public void init() throws ServletException {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory for user storage system");
        }
        try {
            shoppingListDao = daoFactory.getDAO(ShoppingListDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao factory for product storage system", ex);
        }
    }

%>
<%
    User user = (User) request.getSession().getAttribute("user");
    List<ShoppingList> shoppingLists = new ArrayList();
    if (user != null) {
        shoppingLists.addAll(shoppingListDao.getByUserId(user.getId()));
    } else {
        String userId = null;
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("userId")) {
                    userId = cookie.getValue();
                }
            }
        }
        ShoppingList shoppingList = shoppingListDao.getByCookie(userId);
        if (shoppingList != null) {
            shoppingLists.add(shoppingList);
        }
    }
    pageContext.setAttribute("shoppingLists", shoppingLists);
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Liste</title>
        <%@include file="../include/generalMeta.jsp" %>
        <style>

            button:focus{
                outline:none;
            }

            a.disabled {
                pointer-events: none;
                cursor: default;
            }
        </style>
        <script>
            function deleteList(id) {
                var xhttp = new XMLHttpRequest();
                xhttp.onreadystatechange = function () {
                    if (this.readyState === 4 && this.status === 204) {
                        var element = document.getElementById(id);
                        element.parentNode.removeChild(element);
                    } else if (this.readyState === 4 && this.status === 400) {
                        alert("Bad request!");
                    } else if (this.readyState === 4 && this.status === 403) {
                        alert("You are not allowed to delete the list!");
                    } else if (this.readyState === 4 && this.status === 500) {
                        alert("Impossible to delete the list!");
                    }
                };
                var url = "${pageContext.response.encodeURL(contextPath.concat("restricted/ShoppingListServlet"))}";
                xhttp.open("DELETE", url + "?shoppingListId=" + id, true);
                xhttp.send();
            }
            function showAnteprima(id) {
                $.ajax({
                    url: "${pageContext.response.encodeURL(contextPath.concat("restricted/ShoppingListServlet"))}",
                    dataType: "json",
                    data: {
                        shoppingListId: id,
                        res: 0
                    },
                    success: function (data) {
                        console.log(data);
                        $("#anteprima").html("");
                        for (var i in data.products) {
                            $("#anteprima").append("<li id = \"" + data.products[i].id + "\" class = \"list-group-item justify-content-between align-items-center my-list-item\" >" +
                                    "<input type=\"checkbox\" id=\"checkbox_" + data.products[i].id + "\" " + ((data.products[i].necessary === "false") ? "checked" : "") + " onclick=\"checkProduct(" + id + "," + data.products[i].id + ")\">" +
                                    "<label for=\"checkbox_" + data.products[i].id + "\">" +
                                    "<img src=\"${contextPath}images/productCategories/icons/" + data.products[i].logoPath + "\" class=\"medium-logo\">" +
                                    "<div class=\"my-text-content\">" + data.products[i].name + "</div>" +
                                    "</label>" +
                                    "</li>");
                        }
                        return false;
                    },
                    error(xhr, status, error) {
                        console.log("error: " + error);
                    }
                });
            }
            /* SETTA UN PRODOTTO COME SETTATO/NON SETTATO */
            function checkProduct(shoppingListId, productId) {
                $.ajax({
                    url: "${pageContext.response.encodeURL(contextPath.concat("ProductListServlet"))}",
                    data: {
                        shoppingListId: shoppingListId,
                        productId: productId,
                        action: function () {
                            if ($("#checkbox_" + productId).is(":checked")) {
                                return 1;
                            } else {
                                return 2;
                            }
                        }
                    },
                    success: function (data) {
                        return false;
                    },
                    error(xhr, status, error) {
                        console.log(error);
                        alert("L'utente non ha i permessi per la modifica della lista");
                        if ($("#checkbox_" + productId).is(":checked")) {
                            $("#checkbox_" + productId).prop('checked', false);
                        } else {
                            $("#checkbox_" + productId).prop('checked', false);
                        }
                    }
                });
            }
        </script>
    </head>
    <body>
        <div id="containerPage">
            <div id="header">
                <div class="jumbotron">
                    <div class="container text-center">
                        <h1>Liste della spesa di ${user.firstName}</h1>      
                    </div>
                </div>
                <%@include file="../include/navigationBar.jsp"%>
            </div>
            <div id="body">
                <div class="container-fluid">
                    <div class="col-sm-1">
                    </div>
                    <div class="col-sm-5">
                        <div class="pre-scrollable">
                            <ul class="list-group">
                                <li>
                                    <button onclick="window.location.href = '${pageContext.response.encodeURL(contextPath.concat("shoppingListForm.jsp"))}'" class="list-group-item list-group-item-action my-list-item">

                                        <div class="my-text-content">
                                            Aggiungi nuova lista
                                        </div>
                                        <img class="list-logo-right" src="${contextPath}images/myIconsNav/plus.png">
                                    </button>
                                </li>
                                <c:set var="i" value="0"/>    
                                <c:forEach items="${shoppingLists}" var="shoppingList">
                                    <li id="${shoppingList.id}">
                                        <button class="list-group-item group-item-custom my-list-item wrap" onclick="showAnteprima(${shoppingList.id})">
                                            <div class="flex">
                                                <img src="${contextPath}images/shoppingListCategories/${shoppingList.listCategoryIcon}" class="medium-logo"> 
                                                <div class="my-text-content flex">
                                                    ${shoppingList.name}${shoppingList.notifications}
                                                </div>
                                            </div>
                                            <div class="pull-right">
                                                <img class="rubbish" onclick="deleteList(${shoppingList.id})">
                                                <span class="list-logo-right" onclick="window.location.href = '${pageContext.response.encodeURL(contextPath.concat("restricted/ShoppingListServlet?res=1&shoppingListId=").concat(shoppingList.id))}';
                                                        event.stopPropagation();">
                                                    <span class="glyphicon glyphicon-list-alt"></span>
                                                </span>
                                            </div>
                                        </button>
                                    </li>
                                    <c:set var="i" value="${i + 1}"/>
                                </c:forEach>
                            </ul>
                        </div>
                    </div>
                    
                    <div class="col-sm-5">
                        <div id="anteprima" class="list-group" >
                        </div>
                    </div>
                </div>
            </div>
            <%@include file="../include/footer.jsp" %>
        </div>
    </body>
</html>

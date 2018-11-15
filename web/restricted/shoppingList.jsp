<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="db.entities.ShoppingList"%>
<%@page import="db.entities.Product"%>
<%@page import="db.entities.User"%>
<%@page import="db.exceptions.DAOFactoryException"%>
<%@page import="db.factories.DAOFactory"%>
<%@page import="db.daos.ShoppingListDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Lista Alimentari</title>
        <%@include file="../include/generalMeta.jsp" %>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.6-rc.0/css/select2.min.css" crossorigin="anonymous">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.6-rc.0/js/select2.min.js" crossorigin="anonymous"></script>

        <script>
            /* FUNZIONE RICERCA E AGGIUNTA DEI PRODOTTI */
            $(function () {
                function formatOption(option) {
                    var res = $('<span class="optionClick" onClick="addprod()">' + option.text + '</span>');
                    return res;
                }
                $("#autocomplete-2").select2({
                    placeholder: "Aggiungi un prodotto",
                    allowClear: true,
                    ajax: {
                        url: function (request) {
                            return "ProductsSearchServlet?shoppingListId=${shoppingList.id}&query=" + request.term;
                        },
                        dataType: "json"
                    },
                    templateResult: formatOption
                });
                $("#autocomplete-2").val(null).trigger("change");
                $('#autocomplete-2').on("select2:select", function () {
                    var xhttp = new XMLHttpRequest();
                    xhttp.onreadystatechange = function () {
                        if (this.readyState === 4 && this.status === 200) {
                            $("#prodotti").append("<li id=" + $('#autocomplete-2').find(":selected").val() + " class=\"list-group-item justify-content-between align-items-center\">" + $('#autocomplete-2').find(":selected").text()
                                    + " <span class='pull-right glyphicon glyphicon-remove' style='color:red' onclick='deleteProduct(" + $('#autocomplete-2').find(":selected").val() + ")' title='Elimina'>"
                                    + "</span></li>");
                        } else if (this.readyState === 4 && this.status === 500) {
                            alert("Impossibile aggiungere il prodotto");
                        }
                    };
                    var url = "${pageContext.response.encodeURL("ProductListServlet")}";
                    xhttp.open("GET", url + "?shoppingListId=${shoppingList.id}&productId=" + $('#autocomplete-2').find(":selected").val() + "&action=3", true);
                    xhttp.send();
                });
            });
            /* FUNZIONE DI RICERCA E AGGIUNTA DEGLI UTENTI */
            $(function () {

                function formatOption(option) {
                    var res = $('<span class="optionClick" onClick="addprod()">' + option.text + '</span>');
                    return res;
                }
                $("#autocomplete-3").select2({
                    placeholder: "Cerca utente...",
                    allowClear: true,
                    ajax: {
                        url: function (request) {
                            return "UsersSearchServlet?query=" + request.term;
                        },
                        dataType: "json"
                    },
                    templateResult: formatOption
                });
                $("#autocomplete-3").val(null).trigger("change");
                $('#autocomplete-3').on("select2:select", function () {
                    var xhttp = new XMLHttpRequest();
                    xhttp.onreadystatechange = function () {

                        if (this.readyState === 4 && this.status === 200) {
                            $("#utenti").append("<li id=\"" + $('#autocomplete-3').find(":selected").val() + "\"class=\"list-group-item justify-content-between align-items-center\">" + $('#autocomplete-3').find(":selected").text()
                                    + " <span class=\"pull-right glyphicon glyphicon-remove\" title=\"Elimina\" style=\"color:black;font-size:15px;margin-left:5px;\" onclick=\"deleteUser(" + $('#autocomplete-3').find(":selected").val() + ")\"></span>"
                                    + " <select class=\"pull-right\" onchange=\"changePermissions(" + $('#autocomplete-3').find(":selected").text() + ", this.value)\">"
                                    + "     <option value=1>Visualizza lista</option>"
                                    + "     <option value=2>Modifica lista</option>"
                                    + " </select>"
                                    + " </li>")
                        } else if (this.readyState === 4 && this.status === 500) {
                            alert("Impossibile aggiungere l'utente");
                        }
                    };
                    var url = "${pageContext.response.encodeURL("ShareListsServlet")}";
                    xhttp.open("GET", url + "?action=1&shoppingListId=${shoppingList.id}&userId=" + $('#autocomplete-3').find(":selected").val(), true);
                    xhttp.send();
                });
            });
            /* MODIFICA ASINCRONA DEI PERMESSI DEGLI UTENTI */
            function changePermissions(userId, permission) {
                var xhttp = new XMLHttpRequest();
                xhttp.onreadystatechange = function () {
                    if (this.readyState === 4 && this.status === 200) {
                    } else if (this.readyState === 4 && this.status === 400) {
                        alert("Non hai il permesso per la modifica della lista");
                    } else if (this.readyState === 4 && this.status === 500) {
                        alert("Errore del server, impossibile modificare i permessi");
                    }
                };
                var url = "${pageContext.response.encodeURL("ShareListsServlet")}";
                if (userId !== '' && permission !== '') {
                    xhttp.open("GET", url + "?action=2&shoppingListId=${shoppingList.id}&userId=" + userId + "&permission=" + permission, true);
                    xhttp.send();
                }
            }
            /* RIMUOVI UN PRODOTTO DALLA LISTA */
            function deleteProduct(productId) {
                var xhttp = new XMLHttpRequest();
                xhttp.onreadystatechange = function () {
                    if (this.readyState === 4 && this.status === 200) {
                        var element = document.getElementById(productId);
                        element.parentNode.removeChild(element);
                    } else if (this.readyState === 4 && this.status === 400) {
                        alert("Non hai il permesso per la modifica della lista");
                    } else if (this.readyState === 4 && this.status === 500) {
                        alert("Errore del server, impossibile modificare i prodotti");
                    }
                };
                var url = "${pageContext.response.encodeURL("ProductListServlet")}";
                if (productId !== '') {
                    xhttp.open("GET", url + "?action=0&shoppingListId=${shoppingList.id}&productId=" + productId, true);
                    xhttp.send();
                }
            }
            /* ANNULLA CONDIVISIONE CON UN UTENTE */
            function deleteUser(userId) {
                var xhttp = new XMLHttpRequest();
                xhttp.onreadystatechange = function () {
                    if (this.readyState === 4 && this.status === 200) {
                        var element = document.getElementById(userId);
                        element.parentNode.removeChild(element);
                    } else if (this.readyState === 4 && this.status === 400) {
                        alert("Non hai il permesso per la modifica della lista");
                    } else if (this.readyState === 4 && this.status === 500) {
                        alert("Errore del server, impossibile rimuovere l'utente");
                    }
                };
                var url = "${pageContext.response.encodeURL("ShareListsServlet")}";
                if (userId !== '') {
                    xhttp.open("GET", url + "?action=0&shoppingListId=${shoppingList.id}&userId=" + userId, true);
                    xhttp.send();
                }
            }
            /* AGGIUNTA MESSAGGIO */
            function addMessage() {
                var text = document.getElementById("newtext").value;
                console.log("inizio addMessage:" + text);
                var xhttp = new XMLHttpRequest();
                xhttp.onreadystatechange = function () {
                    console.log("controllo if");
                    if (this.readyState === 4 && this.status === 200) {
                        console.log("messaggio aggiunto");
                        var element = document.getElementById("messageBoard");
                        element.innerHTML += "<div>" + text + "</div>";
                    } else if (this.readyState === 4 && this.status === 400) {
                        alert("Non hai il permesso per la modifica della lista");
                    } else if (this.readyState === 4 && this.status === 500) {
                        alert("Errore del server, impossibile rimuovere l'utente");
                    }
                };
                var url = "${pageContext.response.encodeURL("MessagesServlet")}";
                console.log(url);
                xhttp.open("GET", "MessagesServlet?shoppingListId=${shoppingList.id}&body=" + text, true);
                xhttp.send();
            }
        </script>
    </head>
    <body>

        <div class="jumbotron">
            <img src="../images/shoppingList/${shoppingList.imagePath}" class="fit-image" alt="Immagine lista">
            <h2>${shoppingList.name}</h2>
            <h4>Categoria: ${shoppingListCategory.name}</h4>
            <h4>Descrizione: ${shoppingList.description}</h4>
        </div>

        <%@include file="../include/navigationBar.jsp"%>
        <div class="container-fluid">

            <div class="col-sm-1">
            </div>
            <div class="col-sm-5">
                <div class="pre-scrollable">
                    <select id="autocomplete-2" name="autocomplete-2" class="form-control select2-allow-clear">
                    </select>
                    <ul id="prodotti" class="list-group">
                        <c:forEach items="${products}" var="product">
                            <li id="${product.id}" class="list-group-item justify-content-between align-items-center">${product.name} 
                                <span class="pull-right glyphicon glyphicon-remove" style="color:red" onclick='deleteProduct(${product.id})' title="Elimina"></span>
                            </li>
                        </c:forEach>
                        <!--<input type="text" class="form-control" placeholder="Cerca prodotto da aggiungere...">-->
                    </ul>
                </div>
            </div>
            <div class="col-sm-1">
            </div>
            <div class="col-sm-4">
                <div class="row">

                    <div>
                        <label for="comment">Chat:</label>
                        <div class="form-control" id="messageBoard"></div>
                    </div>
                    <div class="input-group">
                        <input id="newtext" class="form-control" type="text">
                        <div class="input-group-btn">
                            <button class="btn btn-default" onclick="addMessage()">Invia</button>
                        </div>
                    </div>

                </div>
                <br>
                <div class="row">

                    <ul id="utenti" class="list-group user-list-group">
                        <li class="list-group-item justify-content-between align-items-center">
                            <label> Utenti che condividono la lista: </label>
                            <select id="autocomplete-3" name="autocomplete-3" class="form-control select2-allow-clear">
                            </select></li>
                            <c:forEach items="${users}" var="user">
                            <li id="${user.id}" class="list-group-item justify-content-between align-items-center">${user.firstName} ${user.lastName}  
                                <span class="pull-right glyphicon glyphicon-remove" title="Elimina" style="color:black;font-size:15px;margin-left:5px;" onclick="deleteUser(${user.id})"></span>
                                <select class="pull-right" onchange="changePermissions(${user.id}, this.value)">
                                    <option value=1 <c:if test="${user.permissions==1}">selected</c:if>>Visualizza lista</option>
                                    <option value=2 <c:if test="${user.permissions==2}">selected</c:if>>Modifica lista</option>
                                    </select>  
                                </li>
                        </c:forEach>
                    </ul>
                </div>

            </div>

        </div>
        <%@include file="../include/footer.jsp" %>
    </body>
</html>

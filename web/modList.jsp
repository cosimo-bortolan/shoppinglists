<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="it">
    <head>
        <title>Modifica Liste</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <link rel="stylesheet" type="text/css" href="css/default-element.css">
        <link rel="stylesheet" type="text/css" href="css/immagini.css">
        <link rel="stylesheet" type="text/css" href="css/form.css">
        
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
        
        </head>
        <body>
            <div class="container text-center">    
            <h2>Area di modifica delle liste</h2><br>
            <h4>Modifica le caratteristiche e le immagini delle liste<br>o creane una nuova</h4><br>
            <br>
            <div class="col-sm-2">
            </div>
            <div class="col-sm-8">
                <div class="form-container ">
                    <form class="form-signin" action="${pageContext.response.encodeURL("ShoppingListServlet")}" method="POST" enctype="multipart/form-data">
                        <c:choose>
                            <c:when test="${message==1}">
                                Compila i campi mancanti!
                                <c:if test="${empty shoppingList.name}">Name</c:if>
                                <c:if test="${empty shoppingList.description}">Description</c:if>
                                <c:if test="${empty shoppingList.listCategoryId}">Category</c:if>
                                <c:if test="${empty shoppingList.imagePath}">Image</c:if>
                            </c:when>
                        </c:choose>
                        <div class="form-group">
                            <label for="name">Nome Lista: </label>
                            <input type="text" id="name" name="name" class="form-control" placeholder="Nome" value="${shoppingList.name}" autofocus>
                        </div>
                        <div class="form-group">
                            <label for="description">Descrizione Lista: </label>
                            <input type="text" id="description" name="description" class="form-control" placeholder="Descrizione" value="${shoppingList.description}">
                        </div>
                        <div class="form-group">
                            <label for="shoppingListCategory">Categoria della lista: </label>
                            <select id="shoppingListCategory" name="shoppingListCategory" class="form-control">
                                <option value="" <c:if test="${empty shoppingList.listCategoryId}">selected</c:if> disabled>Seleziona la categoria della Lista...</option>
                                <c:forEach items="${shoppingListCategories}" var="shoppingListCategory">
                                    <option value="${shoppingListCategory.id}" <c:if test="${shoppingListCategory.id==shoppingList.listCategoryId}">selected</c:if>>${shoppingListCategory.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">

                            <c:if test="${not empty shoppingList.imagePath}">
                                <img src="../images/shoppingList/<c:out value="${shoppingList.imagePath}"/>" class="big-logo">
                            </c:if>
                            <label for="logo">Aggiungi nuova immagine:</label>
                            <input type="file" id="logo" name="image" class="form-control">
                        </div>
                        <c:if test="${not empty shoppingList.id}"><input type="hidden" name="shoppingListId" value="${shoppingList.id}"></c:if>
                            <button type="submit" class="btn btn-default acc-btn">Conferma</button>
                        </form>
                    </div>
                    <h3><a style="color:black" href="mainpagenologged.html"><span class="glyphicon glyphicon-home"></span> Home</a></h3>
                </div>

            </div>


            <footer class="container-fluid text-center">
                <p>&copy; 2018, ListeSpesa.it, All right reserved</p> 
            </footer>
        <c:remove var="message" scope="session" />
        <c:remove var="shoppingList" scope="session" />
    </body>
</html>
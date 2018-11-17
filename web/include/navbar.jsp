<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script>
    /* FUNZIONE RICERCA PRODOTTI PUBBLICI E PRIVATI PER L'UTENTE LOGGATO */
    $(function () {
        function formatOption(option) {
            var res = $('<span class="optionClick">' + option.text + '</span>');
            console.log(option.text);
            return res;
        }
        $("#searchProducts").select2({
            placeholder: "Cerca prodotti...",
            allowClear: true,
            ajax: {
                url: function (request) {
                    return "ProductsSearchServlet?query=" + request.term;

                },
                dataType: "json"
            },
            templateResult: formatOption
        });
        $("#searchProducts").val(null).trigger("change");
        $('#searchProducts').on("select2:select", function () {
            var url = "${pageContext.response.encodeURL("/shoppinglists/restricted/ProductServlet?res=1&productId=")}" + $('#searchProducts').find(":selected").val();
            console.log(url);
            window.location.href = url;
        });
    });
        /* FUNZIONE RICERCA PRODOTTI PUBBLICI PER L'UTENTE non LOGGATO */
    $(function () {
        function formatOption(option) {
            var res = $('<span class="optionClick">' + option.text + '</span>');
            console.log(option.text);
            return res;
        }
        $("#searchPublicProducts").select2({
            placeholder: "Cerca prodotti...",
            allowClear: true,
            ajax: {
                url: function (request) {
                    return "ProductsSearchPublic?query=" + request.term;

                },
                dataType: "json"
            },
            templateResult: formatOption
        });
        $("#searchPublicProducts").val(null).trigger("change");
        $('#searchPublicProducts').on("select2:select", function () {
            var url = "${pageContext.response.encodeURL("ProductPublic?productId=")}" + $('#searchPublicProducts').find(":selected").val();
            console.log(url);
            window.location.href = url;
        });
    });
</script>

<nav class="navbar navbar-inverse ">
     <div class="navbar-header pull-left">
        <a class="navbar-brand" style="color:white" href="/shoppinglists/index.jsp"><span class="glyphicon glyphicon-home"></span> Home</a>
     </div>
        <div class="navbar-header pull-left">
             <form class="navbar-form " role="search">
      <div class="form-group">
          <c:choose>
                    <c:when test="${empty user}">
                        <select id="searchPublicProducts" name="searchPublicProducts" class="form-control select2-allow-clear mr-sm-2">
                        </select>
                    </c:when>
                    <c:when test="${not empty user}">
                        <select id="searchProducts" name="searchProducts" class="form-control select2-allow-clear">
                        </select>
                    </c:when>
                </c:choose>
    
      </div>
    </form>
        </div>
        <div class="navbar-header pull-right">
        <ul class="nav navbar-nav">
             <c:choose>
                <c:when test="${not empty user}">
                    <li style="display: inline-block !important;">
                        <a class="nav-link" href="${pageContext.response.encodeURL("/shoppinglists/restricted/user.jsp")}" style="color:white">
                            <span class="glyphicon glyphicon-user"></span>
                            <span class="hidden-sm hidden-xs">PROFILO</span>
                        </a>
                    </li>
                    <li style="display: inline-block !important;"><a class="nav-link" href="${pageContext.response.encodeURL("/shoppinglists/Logout")}" style="color:white"><span class="glyphicon glyphicon-log-out"></span> <span class="hidden-sm hidden-xs">LOGOUT</span></a></li>
                    </c:when>
                    <c:when test="${empty user}">
                    <li style="display: inline-block !important;"><a class="nav-link" href="${pageContext.response.encodeURL("/shoppinglists/login.jsp")}" style="color:white"><span class="glyphicon glyphicon-log-out"></span> <span class="hidden-sm hidden-xs">LOGIN</span></a></li>
                    </c:when>
                </c:choose>
                    <li class="dropdown" style="display: inline-block !important;">
                        <a class="nav-link dropdown-toggle" data-toggle="dropdown" style="color:white" href="#">
                            <span class="glyphicon glyphicon-menu-hamburger"></span>
                            <span class="hidden-sm hidden-xs">MEN&Ugrave;</span>
                        </a>
                <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                    <a class="dropdown-item" href="${pageContext.response.encodeURL("/shoppinglists/restricted/shoppingLists.jsp")}">Le mie liste</a>
                    <a class="dropdown-item" href="${pageContext.response.encodeURL("/shoppinglists/restricted/shoppingListForm.jsp")}">Nuova lista</a>
                    <div class="dropdown-divider"></div>
                    <a class="dropdown-item" href="${pageContext.response.encodeURL("/shoppinglists/restricted/products.jsp")}">I miei prodotti</a>
                    <a class="dropdown-item" href="${pageContext.response.encodeURL("/shoppinglists/restricted/productsForm.jsp")}">Aggiungi prodotto</a>
                    <div class="dropdown-divider"></div>
                    <a class="dropdown-item" href="${pageContext.response.encodeURL("/shoppinglists/restricted/shoppingListCategories.jsp")}">Categorie lista</a>
                    <a class="dropdown-item" href="${pageContext.response.encodeURL("/shoppinglists/restricted/shoppingListCategoryForm.jsp")}">Nuova categoria lista</a>
                    <a class="dropdown-item" href="${pageContext.response.encodeURL("/shoppinglists/restricted/productsCategories.jsp")}">Categorie prodotto</a>
                    <a class="dropdown-item" href="${pageContext.response.encodeURL("/shoppinglists/restricted/productCategory.jsp")}">Nuova categoria prodotto</a>
                </div>
            </li>
        </ul>
        </div>
</nav>
 
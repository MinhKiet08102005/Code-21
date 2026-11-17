<%-- Khach hang tim kiem mon an, combo; xem chi tiet mon. --%>
<% String PAGE_TITLE = "Thực đơn"; String MENU = "menu"; String SIZE = "l"; %>
<%
    String q = request.getParameter("q");
    int cat = Format0.parseInt(request.getParameter("cat"), 0);
    List<DishCategory0> categories = new DishCategoryDAO0().getCategories();
    List<Dish0> dishes = new ArrayList<>();
    for (Dish0 d : new DishDAO0().searchDish(q)) if (cat == 0 || d.getCategory().getId() == cat) dishes.add(d);
    List<Combo0> combos = cat == 0 ? new ComboDAO0().searchCombo(q) : new ArrayList<Combo0>();
    Dish0 detail = null;
    int detailId = Format0.parseInt(request.getParameter("id"), 0);
    if (detailId > 0) {
        detail = new DishDAO0().getDishById(detailId);
        if (detail != null && !DishDAO0.AVAILABLE.equals(detail.getStatus())) detail = null;
    }
    String base = "?q=" + java.net.URLEncoder.encode(q == null ? "" : q, "UTF-8") + "&cat=" + cat;
%>
<%@ include file="/common/header_public.jspf" %>
<div class="hero">
    <h1>Thực đơn nhà hàng</h1>
    <p>Tìm món yêu thích, đặt bàn hoặc đặt món trực tuyến chỉ trong vài bước.</p>
    <form class="inline-form" method="get" style="margin-top:16px;">
        <div class="form-row" style="flex:1; max-width:480px;"><input type="text" name="q" value="<%= Format0.h(q) %>" placeholder="Nhập tên món ăn, ví dụ: phở, lẩu, trà đào..."></div>
        <input type="hidden" name="cat" value="<%= cat %>">
        <button class="btn accent" type="submit">Tìm kiếm</button>
    </form>
</div>
<% if (detail != null) { %>
<div class="card" style="display:flex; gap:22px; flex-wrap:wrap;">
    <div class="menu-item" style="width:260px; box-shadow:none;"><div class="thumb" style="height:200px;">
        <% if (detail.getImagePath() != null) { %><img src="<%= ctxPath %>/<%= Format0.h(detail.getImagePath()) %>" alt=""><% } else { %><span class="initial"><%= Format0.h(detail.getName().substring(0, 1)) %></span><% } %></div></div>
    <div style="flex:1; min-width:260px;">
        <div class="small muted"><%= Format0.h(detail.getCategory().getName()) %> · <%= detail.getCode() %></div>
        <h2 style="margin:4px 0 8px;"><%= Format0.h(detail.getName()) %></h2>
        <div class="price" style="font-size:22px; font-weight:700; color:var(--accent);"><%= Format0.money(detail.getSellingPrice()) %></div>
        <p><%= Format0.h(detail.getDescription()) %></p>
        <form method="post" action="<%= ctxPath %>/khachhang/OnlineOrderView0.jsp" class="inline-form">
            <input type="hidden" name="action" value="add"><input type="hidden" name="type" value="dish"><input type="hidden" name="itemId" value="<%= detail.getId() %>">
            <input type="hidden" name="back" value="menu">
            <input class="qty-input" type="number" name="qty" value="1" min="1" max="50">
            <button class="btn" type="submit">Thêm vào giỏ đặt món</button>
            <a class="btn secondary" href="<%= base %>">Đóng</a>
        </form>
    </div>
</div>
<% } %>
<div class="tabs">
    <a href="?q=<%= Format0.h(q == null ? "" : q) %>&cat=0" class="<%= cat == 0 ? "active" : "" %>">Tất cả</a>
    <% for (DishCategory0 c : categories) { %>
    <a href="?q=<%= Format0.h(q == null ? "" : q) %>&cat=<%= c.getId() %>" class="<%= cat == c.getId() ? "active" : "" %>"><%= Format0.h(c.getName()) %></a>
    <% } %>
</div>
<% if (!combos.isEmpty()) { %>
<h2>Combo ưu đãi</h2>
<div class="menu-grid" style="margin-bottom:24px;">
    <% for (Combo0 c : combos) { BigDecimal orig = c.getOriginalPrice(); %>
    <div class="menu-item">
        <div class="thumb">🍱</div>
        <div class="body">
            <b><%= Format0.h(c.getName()) %></b>
            <div class="small muted"><% for (ComboDetail0 d : c.getDetails()) { %><%= d.getQuantity() %>× <%= Format0.h(d.getDish().getName()) %>; <% } %></div>
            <div><span class="price"><%= Format0.money(c.getPrice()) %></span> <span class="small muted" style="text-decoration:line-through;"><%= Format0.money(orig) %></span></div>
        </div>
        <form class="foot" method="post" action="<%= ctxPath %>/khachhang/OnlineOrderView0.jsp">
            <input type="hidden" name="action" value="add"><input type="hidden" name="type" value="combo"><input type="hidden" name="itemId" value="<%= c.getId() %>">
            <input type="hidden" name="back" value="menu"><input type="hidden" name="qty" value="1">
            <button class="btn sm" type="submit">+ Thêm vào giỏ</button>
        </form>
    </div>
    <% } %>
</div>
<% } %>
<h2>Món ăn<%= Format0.blank(q) ? "" : " – kết quả cho \"" + Format0.h(q) + "\"" %></h2>
<% if (dishes.isEmpty()) { %>
<div class="card empty">Không tìm thấy món ăn phù hợp. Hãy thử từ khóa khác.</div>
<% } else { %>
<div class="menu-grid">
    <% for (Dish0 d : dishes) { %>
    <div class="menu-item">
        <a class="thumb" href="<%= base %>&id=<%= d.getId() %>"><% if (d.getImagePath() != null) { %><img src="<%= ctxPath %>/<%= Format0.h(d.getImagePath()) %>" alt=""><% } else { %><span class="initial"><%= Format0.h(d.getName().substring(0, 1)) %></span><% } %></a>
        <div class="body">
            <a href="<%= base %>&id=<%= d.getId() %>" style="color:inherit;"><b><%= Format0.h(d.getName()) %></b></a>
            <div class="small muted"><%= Format0.h(d.getCategory().getName()) %></div>
            <div class="price"><%= Format0.money(d.getSellingPrice()) %></div>
        </div>
        <form class="foot" method="post" action="<%= ctxPath %>/khachhang/OnlineOrderView0.jsp">
            <input type="hidden" name="action" value="add"><input type="hidden" name="type" value="dish"><input type="hidden" name="itemId" value="<%= d.getId() %>">
            <input type="hidden" name="back" value="menu"><input type="hidden" name="qty" value="1">
            <button class="btn sm" type="submit">+ Thêm vào giỏ</button>
            <a class="small" href="<%= base %>&id=<%= d.getId() %>">Chi tiết</a>
        </form>
    </div>
    <% } %>
</div>
<% } %>
<%@ include file="/common/footer_public.jspf" %>

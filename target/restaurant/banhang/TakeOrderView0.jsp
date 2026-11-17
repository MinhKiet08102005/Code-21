<%-- Ghi nhan goi mon tai ban. --%>
<% String REQUIRED_ROLE = "SALE"; String PAGE_TITLE = "Ghi nhận gọi món"; String MENU = "order"; String SIZE = "l"; %>
<%@ include file="/common/guard.jspf" %>
<%
    OrderDAO0 orderDAO = new OrderDAO0();
    int tableId = Format0.parseInt(request.getParameter("table"), 0);
    Order0 order = tableId > 0 ? orderDAO.getActiveOrderByTable(tableId) : null;
    List<Order0> serving = order == null ? orderDAO.getServingOrders() : null;
    String q = request.getParameter("q");
    List<Dish0> dishes = order != null ? new DishDAO0().searchDish(q) : null;
    List<Combo0> combos = order != null ? new ComboDAO0().searchCombo(q) : null;
%>
<%@ include file="/common/header.jspf" %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Ghi nhận gọi món</div>
        <h1>Ghi nhận gọi món<%= order != null ? " – Bàn " + order.getTable().getTableNumber() : "" %></h1>
    </div>
    <% if (order != null) { %><a class="btn secondary" href="<%= ctxPath %>/banhang/TakeOrderView0.jsp">Chọn bàn khác</a><% } %>
</div>
<% if (order == null) { %>
<div class="card">
    <h3>Chọn bàn đang phục vụ</h3>
    <% if (tableId > 0) { %><div class="alert warn">Bàn này chưa có khách. Hãy tiếp nhận khách trước.</div><% } %>
    <% if (serving.isEmpty()) { %>
    <div class="empty">Chưa có bàn nào đang phục vụ. <a href="<%= ctxPath %>/banhang/ReceiveCustomerView0.jsp">Tiếp nhận khách</a></div>
    <% } else { %>
    <div class="table-map">
        <% for (Order0 o : serving) { %>
        <a class="table-cell busy" href="?table=<%= o.getTable().getId() %>" style="color:inherit; text-decoration:none;">
            <b>Bàn <%= o.getTable().getTableNumber() %></b>
            <div class="small muted"><%= o.getCode() %> · <%= o.getDetails().size() %> món</div>
            <div class="small"><%= Format0.money(o.getTotalAmount()) %></div>
        </a>
        <% } %>
    </div>
    <% } %>
</div>
<% } else { %>
<div class="grid grid-2" style="align-items:start;">
    <div class="card">
        <h3>Thực đơn</h3>
        <form class="inline-form" method="get" style="margin-bottom:12px;">
            <input type="hidden" name="table" value="<%= tableId %>">
            <div class="form-row" style="flex:1;"><input type="text" name="q" value="<%= Format0.h(q) %>" placeholder="Tìm món hoặc combo..."></div>
            <button class="btn secondary" type="submit">Tìm</button>
        </form>
        <div class="table-wrap" style="max-height: 560px; overflow:auto;">
            <table class="tbl">
                <thead><tr><th>Món / combo</th><th class="num">Giá</th><th>SL</th><th></th></tr></thead>
                <tbody>
                <% for (Combo0 c : combos) { %>
                <tr><td><b><%= Format0.h(c.getName()) %></b> <span class="badge orange">combo</span></td><td class="num"><%= Format0.money(c.getPrice()) %></td>
                    <td colspan="2"><form method="post" action="<%= ctxPath %>/banhang/doSaveOrder0.jsp" class="inline-form" style="flex-wrap:nowrap;">
                        <input type="hidden" name="action" value="add"><input type="hidden" name="orderId" value="<%= order.getId() %>">
                        <input type="hidden" name="type" value="combo"><input type="hidden" name="itemId" value="<%= c.getId() %>">
                        <input class="qty-input" type="number" name="qty" value="1" min="1" max="50"><button class="btn sm" type="submit">Thêm</button></form></td></tr>
                <% } %>
                <% for (Dish0 d : dishes) { %>
                <tr><td><%= Format0.h(d.getName()) %> <span class="small muted">· <%= Format0.h(d.getCategory().getName()) %></span></td><td class="num"><%= Format0.money(d.getSellingPrice()) %></td>
                    <td colspan="2"><form method="post" action="<%= ctxPath %>/banhang/doSaveOrder0.jsp" class="inline-form" style="flex-wrap:nowrap;">
                        <input type="hidden" name="action" value="add"><input type="hidden" name="orderId" value="<%= order.getId() %>">
                        <input type="hidden" name="type" value="dish"><input type="hidden" name="itemId" value="<%= d.getId() %>">
                        <input class="qty-input" type="number" name="qty" value="1" min="1" max="50"><button class="btn sm" type="submit">Thêm</button></form></td></tr>
                <% } %>
                <% if (dishes.isEmpty() && combos.isEmpty()) { %><tr><td colspan="4" class="empty">Không có món phù hợp.</td></tr><% } %>
                </tbody>
            </table>
        </div>
    </div>
    <div class="card">
        <div class="card-head"><h3 style="margin:0;">Đơn <%= order.getCode() %></h3><span class="small muted">Mở lúc <%= Format0.dateTime(order.getOrderTime()) %></span></div>
        <div class="table-wrap"><table class="tbl">
            <thead><tr><th>Món</th><th class="num">Đơn giá</th><th>Số lượng</th><th class="num">Thành tiền</th><th></th></tr></thead>
            <tbody>
            <% for (OrderDetail0 d : order.getDetails()) { %>
            <tr><td><%= Format0.h(d.getItemName()) %></td><td class="num"><%= Format0.money(d.getUnitPrice()) %></td>
                <td><form method="post" action="<%= ctxPath %>/banhang/doSaveOrder0.jsp" class="inline-form" style="flex-wrap:nowrap;">
                    <input type="hidden" name="action" value="update"><input type="hidden" name="orderId" value="<%= order.getId() %>"><input type="hidden" name="detailId" value="<%= d.getId() %>">
                    <input class="qty-input" type="number" name="qty" value="<%= d.getQuantity() %>" min="1" max="50" onchange="this.form.submit()"></form></td>
                <td class="num"><%= Format0.money(d.getAmount()) %></td>
                <td><form method="post" action="<%= ctxPath %>/banhang/doSaveOrder0.jsp" style="margin:0;">
                    <input type="hidden" name="action" value="remove"><input type="hidden" name="orderId" value="<%= order.getId() %>"><input type="hidden" name="detailId" value="<%= d.getId() %>">
                    <button class="btn link danger" type="submit">Bỏ</button></form></td></tr>
            <% } %>
            <% if (order.getDetails().isEmpty()) { %><tr><td colspan="5" class="empty">Bàn chưa gọi món nào.</td></tr><% } %>
            </tbody>
            <tfoot><tr><td colspan="3">Tổng tiền</td><td class="num"><%= Format0.money(order.getTotalAmount()) %></td><td></td></tr></tfoot>
        </table></div>
        <div class="actions" style="margin-top:14px;">
            <a class="btn accent" href="<%= ctxPath %>/banhang/PaymentView0.jsp?order=<%= order.getId() %>">Thanh toán bàn này</a>
        </div>
    </div>
</div>
<% } %>
<%@ include file="/common/footer.jspf" %>

<%-- Trang chu nhan vien ban hang: so do ban va viec can xu ly. --%>
<% String REQUIRED_ROLE = "SALE"; String PAGE_TITLE = "Trang chủ nhân viên bán hàng"; String MENU = "home"; String SIZE = "l"; %>
<%@ include file="/common/guard.jspf" %>
<%
    List<DiningTable0> tables = new DiningTableDAO0().getTables();
    Map<Integer, Order0> active = new HashMap<>();
    for (Order0 o : new OrderDAO0().getServingOrders()) if (o.getTable() != null) active.put(o.getTable().getId(), o);
    int pendingRes = new TableReservationDAO0().getReservationsByStatus(TableReservationDAO0.PENDING).size();
    int pendingOnline = new OrderDAO0().getPendingOnlineOrders().size();
    int free = 0;
    for (DiningTable0 t : tables) if (DiningTableDAO0.FREE.equals(t.getStatus())) free++;
%>
<%@ include file="/common/header.jspf" %>
<p class="line">Nhân viên: <%= Format0.h(currentStaff.getFullName()) %></p>
<p class="line">Chức vụ: Nhân viên bán hàng · Ngày <%= Format0.date(LocalDate.now()) %></p>
<div class="actions" style="margin-bottom:16px;">
    <a class="btn" href="<%= ctxPath %>/banhang/ReceiveCustomerView0.jsp">Tiếp nhận khách</a>
    <a class="btn" href="<%= ctxPath %>/banhang/PaymentView0.jsp">Thanh toán</a>
</div>
<div class="grid grid-4" style="margin-bottom:20px;">
    <div class="stat"><div class="label">Bàn trống</div><div class="value"><%= free %> / <%= tables.size() %></div></div>
    <div class="stat"><div class="label">Bàn đang phục vụ</div><div class="value"><%= active.size() %></div></div>
    <a class="stat" href="<%= ctxPath %>/banhang/ConfirmReservationView0.jsp" style="color:inherit;"><div class="label">Đặt bàn chờ xác nhận</div><div class="value"><%= pendingRes %></div></a>
    <a class="stat" href="<%= ctxPath %>/banhang/ConfirmReservationView0.jsp#online" style="color:inherit;"><div class="label">Đơn trực tuyến chờ xác nhận</div><div class="value"><%= pendingOnline %></div></a>
</div>
<div class="card">
    <div class="card-head"><h3 style="margin:0;">Sơ đồ bàn</h3><span class="small muted"><span class="badge green">Trống</span> <span class="badge orange">Có khách</span></span></div>
    <div class="table-map">
        <% for (DiningTable0 t : tables) { Order0 o = active.get(t.getId()); boolean busy = !DiningTableDAO0.FREE.equals(t.getStatus()); %>
        <div class="table-cell <%= busy ? "busy" : "free" %>">
            <b>Bàn <%= t.getTableNumber() %></b> <span class="small muted">· <%= t.getCapacity() %> chỗ</span>
            <div class="small muted"><%= Format0.h(t.getLocation()) %></div>
            <% if (o != null) { %>
            <div class="small" style="margin:6px 0;"><%= o.getCode() %> · <%= Format0.money(o.getTotalAmount()) %></div>
            <a class="btn sm" href="<%= ctxPath %>/banhang/TakeOrderView0.jsp?table=<%= t.getId() %>">Gọi món</a>
            <a class="btn sm secondary" href="<%= ctxPath %>/banhang/PaymentView0.jsp?order=<%= o.getId() %>">Thanh toán</a>
            <% } else { %>
            <div class="small" style="margin:6px 0;"><span class="badge green"><%= Format0.h(t.getStatus()) %></span></div>
            <a class="btn sm secondary" href="<%= ctxPath %>/banhang/ReceiveCustomerView0.jsp?guests=<%= t.getCapacity() %>">Xếp khách</a>
            <% } %>
        </div>
        <% } %>
    </div>
</div>
<%@ include file="/common/footer.jspf" %>

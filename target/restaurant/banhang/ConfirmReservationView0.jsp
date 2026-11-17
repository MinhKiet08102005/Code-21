<%-- Xac nhan thong tin dat ban va don dat mon truc tuyen. --%>
<% String REQUIRED_ROLE = "SALE"; String PAGE_TITLE = "Xác nhận đặt bàn, đơn trực tuyến"; String MENU = "confirm"; String SIZE = "l"; %>
<%@ include file="/common/guard.jspf" %>
<%
    TableReservationDAO0 resDAO = new TableReservationDAO0();
    OrderDAO0 orderDAO = new OrderDAO0();
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        int id = Format0.parseInt(request.getParameter("id"), 0);
        if ("confirmRes".equals(action)) {
            TableReservation0 r = resDAO.getReservationById(id);
            int tableId = Format0.parseInt(request.getParameter("tableId"), 0);
            DiningTable0 t = new DiningTableDAO0().getTableById(tableId);
            String conflict = null;
            if (r != null && t != null) {
                for (TableReservation0 other : resDAO.getReservationsByStatus(TableReservationDAO0.CONFIRMED)) {
                    if (other.getTable() != null && other.getTable().getId() == tableId
                            && Math.abs(java.time.Duration.between(other.getReservationTime(), r.getReservationTime()).toMinutes()) < 120) {
                        conflict = "Bàn " + t.getTableNumber() + " đã được xếp cho phiếu " + other.getCode() + " lúc " + Format0.dateTime(other.getReservationTime()) + ". Vui lòng chọn bàn khác.";
                    }
                }
            }
            if (r == null || t == null) session.setAttribute("flashErr", "Vui lòng chọn bàn cho phiếu đặt bàn.");
            else if (t.getCapacity() < r.getNumberOfGuests()) session.setAttribute("flashErr", "Bàn " + t.getTableNumber() + " không đủ chỗ cho " + r.getNumberOfGuests() + " khách.");
            else if (conflict != null) session.setAttribute("flashErr", conflict);
            else if (resDAO.confirmReservation(id, tableId, currentStaff.getId()))
                session.setAttribute("flashOk", "Đã xác nhận phiếu " + r.getCode() + ", xếp bàn " + t.getTableNumber() + ".");
            else session.setAttribute("flashErr", "Phiếu đã được xử lý trước đó.");
        } else if ("rejectRes".equals(action)) {
            if (resDAO.rejectReservation(id, currentStaff.getId())) session.setAttribute("flashOk", "Đã từ chối phiếu đặt bàn.");
        } else if ("confirmOrder".equals(action)) {
            if (orderDAO.confirmOnlineOrder(id, currentStaff.getId())) session.setAttribute("flashOk", "Đã xác nhận đơn đặt món trực tuyến. Đơn chuyển sang chờ thanh toán.");
            else session.setAttribute("flashErr", "Đơn đã được xử lý trước đó.");
        } else if ("rejectOrder".equals(action)) {
            if (orderDAO.rejectOnlineOrder(id, currentStaff.getId())) session.setAttribute("flashOk", "Đã từ chối đơn đặt món trực tuyến.");
        }
        response.sendRedirect(request.getContextPath() + "/banhang/ConfirmReservationView0.jsp");
        return;
    }
    List<TableReservation0> pending = resDAO.getReservationsByStatus(TableReservationDAO0.PENDING);
    List<TableReservation0> confirmed = resDAO.getReservationsByStatus(TableReservationDAO0.CONFIRMED);
    List<Order0> online = orderDAO.getPendingOnlineOrders();
    List<DiningTable0> tables = new DiningTableDAO0().getTables();
%>
<%@ include file="/common/header.jspf" %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Xác nhận đặt bàn, đơn trực tuyến</div>
        <h1>Xác nhận đặt bàn và đơn đặt món trực tuyến</h1>
    </div>
</div>
<div class="card">
    <h3>Phiếu đặt bàn chờ xác nhận (<%= pending.size() %>)</h3>
    <div class="table-wrap"><table class="tbl">
        <thead><tr><th>Mã</th><th>Khách hàng</th><th>Thời gian đến</th><th class="num">Số khách</th><th>Ghi chú</th><th>Xếp bàn</th><th></th></tr></thead>
        <tbody>
        <% for (TableReservation0 r : pending) { %>
        <tr><td><b><%= r.getCode() %></b><div class="small muted">đặt <%= Format0.dateTime(r.getCreatedAt()) %></div></td>
            <td><%= Format0.h(r.getCustomer().getFullName()) %><div class="small muted"><%= Format0.h(r.getCustomer().getPhone()) %></div></td>
            <td><%= Format0.dateTime(r.getReservationTime()) %></td><td class="num"><%= r.getNumberOfGuests() %></td><td class="small"><%= Format0.h(r.getNote()) %></td>
            <td><form method="post" id="f<%= r.getId() %>" style="margin:0;"><input type="hidden" name="action" value="confirmRes"><input type="hidden" name="id" value="<%= r.getId() %>">
                <select name="tableId" style="width:auto;">
                    <% for (DiningTable0 t : tables) { if (t.getCapacity() < r.getNumberOfGuests()) continue; %>
                    <option value="<%= t.getId() %>">Bàn <%= t.getTableNumber() %> · <%= t.getCapacity() %> chỗ · <%= Format0.h(t.getLocation()) %></option>
                    <% } %>
                </select></form></td>
            <td class="nowrap"><button class="btn sm" type="submit" form="f<%= r.getId() %>">Xác nhận</button>
                <form method="post" style="display:inline;"><input type="hidden" name="action" value="rejectRes"><input type="hidden" name="id" value="<%= r.getId() %>">
                    <button class="btn sm secondary" type="submit" onclick="return confirm('Từ chối phiếu đặt bàn này?');">Từ chối</button></form></td></tr>
        <% } %>
        <% if (pending.isEmpty()) { %><tr><td colspan="7" class="empty">Không có phiếu đặt bàn nào chờ xác nhận.</td></tr><% } %>
        </tbody>
    </table></div>
</div>
<div class="card" id="online">
    <h3>Đơn đặt món trực tuyến chờ xác nhận (<%= online.size() %>)</h3>
    <% if (online.isEmpty()) { %><div class="empty">Không có đơn nào chờ xác nhận.</div><% } %>
    <div class="grid grid-2">
    <% for (Order0 o : online) { %>
        <div style="border:1px solid var(--line); border-radius:8px; padding:14px;">
            <div class="card-head" style="margin-bottom:6px;"><b><%= o.getCode() %> · <%= Format0.h(o.getCustomer().getFullName()) %></b><span class="small muted"><%= Format0.dateTime(o.getOrderTime()) %></span></div>
            <div class="small muted">Điện thoại: <%= Format0.h(o.getCustomer().getPhone()) %><%= o.getNote() != null ? " · Ghi chú: " + Format0.h(o.getNote()) : "" %></div>
            <table class="tbl" style="margin:8px 0;">
                <% for (OrderDetail0 d : o.getDetails()) { %><tr><td><%= d.getQuantity() %> × <%= Format0.h(d.getItemName()) %></td><td class="num"><%= Format0.money(d.getAmount()) %></td></tr><% } %>
                <tfoot><tr><td>Tổng</td><td class="num"><%= Format0.money(o.getTotalAmount()) %></td></tr></tfoot>
            </table>
            <form method="post" class="actions" style="margin:0;">
                <input type="hidden" name="id" value="<%= o.getId() %>">
                <button class="btn sm" type="submit" name="action" value="confirmOrder">Xác nhận đơn</button>
                <button class="btn sm secondary" type="submit" name="action" value="rejectOrder" onclick="return confirm('Từ chối đơn này (ví dụ hết nguyên liệu)?');">Từ chối</button>
            </form>
        </div>
    <% } %>
    </div>
</div>
<div class="card">
    <h3>Phiếu đặt bàn đã xác nhận, chờ khách đến</h3>
    <div class="table-wrap"><table class="tbl">
        <thead><tr><th>Mã</th><th>Khách hàng</th><th>Thời gian đến</th><th class="num">Số khách</th><th>Bàn</th><th>Nhân viên xác nhận</th></tr></thead>
        <tbody>
        <% for (TableReservation0 r : confirmed) { %>
        <tr><td><%= r.getCode() %></td><td><%= Format0.h(r.getCustomer().getFullName()) %></td><td><%= Format0.dateTime(r.getReservationTime()) %></td>
            <td class="num"><%= r.getNumberOfGuests() %></td><td><%= r.getTable() != null ? "Bàn " + r.getTable().getTableNumber() : "" %></td><td><%= r.getSaleStaff() != null ? Format0.h(r.getSaleStaff().getFullName()) : "" %></td></tr>
        <% } %>
        <% if (confirmed.isEmpty()) { %><tr><td colspan="6" class="empty">Chưa có.</td></tr><% } %>
        </tbody>
    </table></div>
</div>
<%@ include file="/common/footer.jspf" %>

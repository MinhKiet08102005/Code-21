<%-- Tiep nhan khach: xep ban cho khach vang lai hoac khach da dat ban, mo don goi mon cho ban. --%>
<% String REQUIRED_ROLE = "SALE"; String PAGE_TITLE = "Tiếp nhận khách"; String MENU = "receive"; String SIZE = "l"; %>
<%@ include file="/common/guard.jspf" %>
<%
    DiningTableDAO0 tableDAO = new DiningTableDAO0();
    TableReservationDAO0 resDAO = new TableReservationDAO0();
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        int tableId = Format0.parseInt(request.getParameter("tableId"), 0);
        int resId = Format0.parseInt(request.getParameter("resId"), 0);
        Customer0 customer = null;
        if (resId > 0) {
            TableReservation0 r = resDAO.getReservationById(resId);
            if (r == null || !TableReservationDAO0.CONFIRMED.equals(r.getStatus())) resId = -1;
            else customer = r.getCustomer();
        }
        if (resId < 0) session.setAttribute("flashErr", "Phiếu đặt bàn không hợp lệ.");
        else if (tableId <= 0) session.setAttribute("flashErr", "Vui lòng chọn bàn.");
        else {
            Order0 o = new OrderDAO0().openTableOrder(tableId, currentStaff.getId(), customer, resId);
            if (o == null) session.setAttribute("flashErr", "Không xếp được bàn: bàn vừa có khách khác, vui lòng chọn bàn khác.");
            else {
                DiningTable0 t = tableDAO.getTableById(tableId);
                session.setAttribute("flashOk", "Đã xếp khách vào bàn " + t.getTableNumber() + ", mở đơn " + o.getCode() + ". Mời ghi nhận gọi món.");
                response.sendRedirect(request.getContextPath() + "/banhang/TakeOrderView0.jsp?table=" + tableId);
                return;
            }
        }
        response.sendRedirect(request.getContextPath() + "/banhang/ReceiveCustomerView0.jsp");
        return;
    }
    int guests = Format0.parseInt(request.getParameter("guests"), 0);
    List<DiningTable0> available = guests > 0 ? tableDAO.getAvailableTables(guests) : null;
    List<TableReservation0> confirmed = resDAO.getReservationsByStatus(TableReservationDAO0.CONFIRMED);
    List<DiningTable0> allFree = tableDAO.getAvailableTables(1);
%>
<%@ include file="/common/header.jspf" %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Tiếp nhận khách</div>
        <h1>Tiếp nhận khách</h1>
    </div>
</div>
<div class="grid grid-2" style="align-items:start;">
    <div class="card">
        <h3>Khách vãng lai</h3>
        <form class="inline-form" method="get" style="margin-bottom:14px;">
            <div class="form-row" style="width:160px;">
                <label>Số khách</label>
                <input type="number" name="guests" min="1" max="20" value="<%= guests > 0 ? guests : "" %>" required>
            </div>
            <button class="btn" type="submit">Tìm bàn trống</button>
        </form>
        <% if (available != null) { %>
            <% if (available.isEmpty()) { %>
            <div class="alert warn" style="margin-bottom:0;">Hiện không còn bàn trống đủ <%= guests %> chỗ. Có thể ghép bàn hoặc mời khách chờ.</div>
            <% } else { %>
            <table class="tbl">
                <thead><tr><th>Bàn</th><th>Sức chứa</th><th>Vị trí</th><th></th></tr></thead>
                <tbody>
                <% for (DiningTable0 t : available) { %>
                <tr><td><b>Bàn <%= t.getTableNumber() %></b></td><td><%= t.getCapacity() %> chỗ</td><td><%= Format0.h(t.getLocation()) %></td>
                    <td><form method="post" style="margin:0;"><input type="hidden" name="tableId" value="<%= t.getId() %>"><button class="btn sm" type="submit">Xếp bàn</button></form></td></tr>
                <% } %>
                </tbody>
            </table>
            <% } %>
        <% } else { %>
        <p class="muted small" style="margin:0;">Nhập số khách để xem các bàn trống phù hợp (bàn nhỏ nhất đủ chỗ được gợi ý trước).</p>
        <% } %>
    </div>
    <div class="card">
        <h3>Khách đã đặt bàn (đã xác nhận)</h3>
        <% if (confirmed.isEmpty()) { %><div class="empty">Không có phiếu đặt bàn nào đang chờ khách đến.</div><% } %>
        <% for (TableReservation0 r : confirmed) { %>
        <div style="border:1px solid var(--line); border-radius:8px; padding:12px; margin-bottom:10px;">
            <div class="card-head" style="margin-bottom:6px;">
                <div><b><%= Format0.h(r.getCustomer().getFullName()) %></b> <span class="muted small">· <%= Format0.h(r.getCustomer().getPhone()) %></span></div>
                <span class="badge teal"><%= r.getCode() %></span>
            </div>
            <div class="small"><%= Format0.dateTime(r.getReservationTime()) %> · <%= r.getNumberOfGuests() %> khách<%= r.getTable() != null ? " · đã xếp bàn " + r.getTable().getTableNumber() : "" %></div>
            <% if (r.getNote() != null) { %><div class="small muted">Ghi chú: <%= Format0.h(r.getNote()) %></div><% } %>
            <form class="inline-form" method="post" style="margin-top:8px;">
                <input type="hidden" name="resId" value="<%= r.getId() %>">
                <select name="tableId" style="width:auto;">
                    <% for (DiningTable0 t : allFree) { if (t.getCapacity() < r.getNumberOfGuests()) continue; %>
                    <option value="<%= t.getId() %>" <%= r.getTable() != null && r.getTable().getId() == t.getId() ? "selected" : "" %>>Bàn <%= t.getTableNumber() %> (<%= t.getCapacity() %> chỗ)</option>
                    <% } %>
                </select>
                <button class="btn sm" type="submit">Khách đã đến – nhận bàn</button>
            </form>
        </div>
        <% } %>
    </div>
</div>
<%@ include file="/common/footer.jspf" %>

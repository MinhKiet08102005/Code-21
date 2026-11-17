<%-- Khach hang dat ban truc tuyen; tra cuu phieu dat ban theo so dien thoai. --%>
<% String PAGE_TITLE = "Đặt bàn trực tuyến"; String MENU = "book"; String SIZE = "l"; %>
<%
    @SuppressWarnings("unchecked")
    Map<String, String> errors = (Map<String, String>) request.getAttribute("errors");
    if (errors == null) errors = new HashMap<>();
    String lookup = Format0.trim(request.getParameter("lookup"));
    List<TableReservation0> mine = lookup.isEmpty() ? null : new TableReservationDAO0().getReservationsByPhone(lookup);
    String minTime = LocalDateTime.now().plusMinutes(30).withSecond(0).withNano(0).toString();
    String vTime = request.getParameter("reservationTime");
%>
<%@ include file="/common/header_public.jspf" %>
<div class="page-head"><div><h1>Đặt bàn trực tuyến</h1><div class="muted">Nhà hàng mở cửa 10:00 – 22:00. Nhân viên sẽ xác nhận và xếp bàn cho bạn.</div></div></div>
<div class="grid grid-2" style="align-items:start;">
    <div class="card">
        <h3>Thông tin đặt bàn</h3>
        <% if (errors.containsKey("general")) { %><div class="alert err"><%= errors.get("general") %></div><% } %>
        <form method="post" action="<%= ctxPath %>/khachhang/doSaveReservation0.jsp" novalidate>
            <div class="form-row <%= errors.containsKey("fullName") ? "field-error" : "" %>"><label>Họ tên <span class="req">*</span></label>
                <input type="text" name="fullName" value="<%= Format0.h(request.getParameter("fullName")) %>" maxlength="100">
                <% if (errors.containsKey("fullName")) { %><div class="err-text"><%= errors.get("fullName") %></div><% } %></div>
            <div class="grid grid-2">
                <div class="form-row <%= errors.containsKey("phone") ? "field-error" : "" %>"><label>Số điện thoại <span class="req">*</span></label>
                    <input type="tel" name="phone" value="<%= Format0.h(request.getParameter("phone")) %>" maxlength="10">
                    <% if (errors.containsKey("phone")) { %><div class="err-text"><%= errors.get("phone") %></div><% } %></div>
                <div class="form-row <%= errors.containsKey("email") ? "field-error" : "" %>"><label>Email</label>
                    <input type="email" name="email" value="<%= Format0.h(request.getParameter("email")) %>">
                    <% if (errors.containsKey("email")) { %><div class="err-text"><%= errors.get("email") %></div><% } %></div>
            </div>
            <div class="grid grid-2">
                <div class="form-row <%= errors.containsKey("time") ? "field-error" : "" %>"><label>Ngày giờ đến <span class="req">*</span></label>
                    <input type="datetime-local" name="reservationTime" min="<%= minTime %>" value="<%= Format0.h(vTime) %>">
                    <% if (errors.containsKey("time")) { %><div class="err-text"><%= errors.get("time") %></div><% } %></div>
                <div class="form-row <%= errors.containsKey("guests") ? "field-error" : "" %>"><label>Số người <span class="req">*</span></label>
                    <input type="number" name="numberOfGuests" min="1" max="20" value="<%= Format0.h(request.getParameter("numberOfGuests") == null ? "2" : request.getParameter("numberOfGuests")) %>">
                    <% if (errors.containsKey("guests")) { %><div class="err-text"><%= errors.get("guests") %></div><% } %></div>
            </div>
            <div class="form-row"><label>Ghi chú</label><textarea name="note" maxlength="500" placeholder="Ví dụ: tổ chức sinh nhật, cần ghế trẻ em..."><%= Format0.h(request.getParameter("note")) %></textarea></div>
            <button class="btn" type="submit">Gửi yêu cầu đặt bàn</button>
        </form>
    </div>
    <div class="card">
        <h3>Tra cứu đặt bàn</h3>
        <form class="inline-form" method="get" style="margin-bottom:12px;">
            <div class="form-row" style="flex:1;"><input type="tel" name="lookup" value="<%= Format0.h(lookup) %>" placeholder="Số điện thoại đã dùng khi đặt"></div>
            <button class="btn secondary" type="submit">Tra cứu</button>
        </form>
        <% if (mine != null) { %>
            <% if (mine.isEmpty()) { %><div class="empty">Không có phiếu đặt bàn nào với số điện thoại này.</div><% } else { %>
            <table class="tbl"><thead><tr><th>Mã</th><th>Thời gian</th><th class="num">Số người</th><th>Trạng thái</th></tr></thead><tbody>
            <% for (TableReservation0 r : mine) { String st = r.getStatus(); %>
            <tr><td><%= r.getCode() %></td><td><%= Format0.dateTime(r.getReservationTime()) %><%= r.getTable() != null ? "<div class='small muted'>Bàn " + r.getTable().getTableNumber() + "</div>" : "" %></td><td class="num"><%= r.getNumberOfGuests() %></td>
                <td><span class="badge <%= TableReservationDAO0.CONFIRMED.equals(st) || TableReservationDAO0.ARRIVED.equals(st) ? "green" : TableReservationDAO0.REJECTED.equals(st) ? "red" : "orange" %>"><%= Format0.h(st) %></span></td></tr>
            <% } %>
            </tbody></table>
            <% } %>
        <% } else { %><p class="muted small" style="margin:0;">Nhập số điện thoại để xem trạng thái các phiếu đặt bàn của bạn.</p><% } %>
    </div>
</div>
<%@ include file="/common/footer_public.jspf" %>

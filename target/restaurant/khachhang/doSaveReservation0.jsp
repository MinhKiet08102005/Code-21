<%-- Xu ly luu phieu dat ban truc tuyen. --%>
<% String PAGE_TITLE = "Đặt bàn trực tuyến"; String MENU = "book"; String SIZE = "s"; %>
<%
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect(request.getContextPath() + "/khachhang/BookTableView0.jsp");
        return;
    }
    Map<String, String> errors = new LinkedHashMap<>();
    String fullName = Format0.trim(request.getParameter("fullName"));
    String phone = Format0.trim(request.getParameter("phone"));
    String email = request.getParameter("email");
    int guests = Format0.parseInt(request.getParameter("numberOfGuests"), 0);
    LocalDateTime time = null;
    try { time = LocalDateTime.parse(request.getParameter("reservationTime")); } catch (Exception ignore) { }
    if (fullName.isEmpty()) errors.put("fullName", "Vui lòng nhập họ tên");
    if (!Format0.validPhone(phone)) errors.put("phone", "Số điện thoại phải gồm 10 chữ số, bắt đầu bằng 0");
    if (!Format0.validEmail(email)) errors.put("email", "Email không đúng định dạng");
    if (time == null) errors.put("time", "Vui lòng chọn ngày giờ đến");
    else if (time.isBefore(LocalDateTime.now().plusMinutes(30))) errors.put("time", "Vui lòng đặt trước ít nhất 30 phút");
    else if (time.toLocalTime().isBefore(LocalTime.of(10, 0)) || time.toLocalTime().isAfter(LocalTime.of(21, 0)))
        errors.put("time", "Nhà hàng nhận khách từ 10:00 đến 21:00");
    else if (time.isAfter(LocalDateTime.now().plusDays(60))) errors.put("time", "Chỉ nhận đặt bàn trong vòng 60 ngày tới");
    if (guests < 1 || guests > 20) errors.put("guests", "Số người từ 1 đến 20 (đoàn lớn hơn vui lòng gọi hotline)");
    TableReservation0 r = null;
    if (errors.isEmpty()) {
        Customer0 c = new CustomerDAO0().getOrCreateCustomer(fullName, phone, email);
        r = new TableReservation0();
        r.setCustomer(c);
        r.setReservationTime(time);
        r.setNumberOfGuests(guests);
        r.setNote(Format0.nullIfBlank(request.getParameter("note")));
        if (c == null || !new TableReservationDAO0().addReservation(r)) errors.put("general", "Không gửi được yêu cầu đặt bàn, vui lòng thử lại.");
    }
    if (!errors.isEmpty()) {
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("/khachhang/BookTableView0.jsp").forward(request, response);
        return;
    }
%>
<%@ include file="/common/header_public.jspf" %>
<div class="result-box">
    <div class="big-ico ok">✓</div>
    <h2>Đã gửi yêu cầu đặt bàn – Mã phiếu: <%= r.getCode() %></h2>
    <p class="muted"><%= Format0.h(fullName) %> · <%= Format0.dateTime(r.getReservationTime()) %> · <%= r.getNumberOfGuests() %> người<br>
        Trạng thái: <b><%= r.getStatus() %></b>. Nhân viên nhà hàng sẽ xác nhận và xếp bàn; bạn có thể tra cứu bằng số điện thoại.</p>
    <div class="actions" style="justify-content:center;">
        <a class="btn" href="<%= ctxPath %>/khachhang/BookTableView0.jsp?lookup=<%= phone %>">Xem trạng thái</a>
        <a class="btn secondary" href="<%= ctxPath %>/khachhang/SearchDishView0.jsp">Xem thực đơn</a>
    </div>
</div>
<%@ include file="/common/footer_public.jspf" %>

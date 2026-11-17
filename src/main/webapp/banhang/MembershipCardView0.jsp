<%-- Lap the thanh vien cho khach hang. --%>
<% String REQUIRED_ROLE = "SALE"; String PAGE_TITLE = "Lập thẻ thành viên"; String MENU = "card"; String SIZE = "l"; %>
<%@ include file="/common/guard.jspf" %>
<%
    CustomerDAO0 customerDAO = new CustomerDAO0();
    MembershipCardDAO0 cardDAO = new MembershipCardDAO0();
    Map<String, String> errors = new LinkedHashMap<>();
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        Customer0 c = null;
        if ("issue".equals(action)) {
            c = customerDAO.getCustomerById(Format0.parseInt(request.getParameter("customerId"), 0));
            if (c == null) errors.put("general", "Không tìm thấy khách hàng.");
        } else {
            String name = Format0.trim(request.getParameter("fullName"));
            String phone = Format0.trim(request.getParameter("phone"));
            String email = request.getParameter("email");
            if (name.isEmpty()) errors.put("fullName", "Vui lòng nhập họ tên khách hàng");
            if (!Format0.validPhone(phone)) errors.put("phone", "Số điện thoại phải gồm 10 chữ số, bắt đầu bằng 0");
            else if (customerDAO.getCustomerByPhone(phone) != null) errors.put("phone", "Số điện thoại đã được đăng ký cho khách hàng khác");
            if (!Format0.validEmail(email)) errors.put("email", "Email không đúng định dạng");
            LocalDate birth = null;
            if (!Format0.blank(request.getParameter("birthDate"))) {
                try { birth = LocalDate.parse(request.getParameter("birthDate")); if (birth.isAfter(LocalDate.now())) errors.put("birthDate", "Ngày sinh không hợp lệ"); }
                catch (Exception e) { errors.put("birthDate", "Ngày sinh không hợp lệ"); }
            }
            if (errors.isEmpty()) {
                c = new Customer0();
                c.setFullName(name);
                c.setPhone(phone);
                c.setEmail(Format0.nullIfBlank(email));
                c.setAddress(Format0.nullIfBlank(request.getParameter("address")));
                c.setBirthDate(birth);
                if (!customerDAO.addCustomer(c)) { errors.put("general", "Không lưu được khách hàng, vui lòng thử lại."); c = null; }
            }
        }
        if (c != null && errors.isEmpty()) {
            if (cardDAO.getCardByCustomer(c.getId()) != null) {
                errors.put("general", "Khách hàng " + c.getFullName() + " đã có thẻ thành viên. Mỗi khách hàng chỉ có một thẻ.");
            } else {
                MembershipCard0 card = new MembershipCard0();
                card.setCustomer(c);
                card.setIssueDate(LocalDate.now());
                card.setTier("Bạc");
                card.setPoints(0);
                card.setIssuedBy((SaleStaff0) currentStaff);
                if (cardDAO.addCard(card)) {
                    session.setAttribute("flashOk", "Đã lập thẻ " + card.getCode() + " cho khách hàng " + c.getFullName() + " (hạng Bạc).");
                    response.sendRedirect(request.getContextPath() + "/banhang/MembershipCardView0.jsp?phone=" + c.getPhone());
                    return;
                }
                errors.put("general", "Không lập được thẻ, vui lòng thử lại.");
            }
        }
    }
    String phone = Format0.trim(request.getParameter("phone"));
    Customer0 found = null;
    MembershipCard0 foundCard = null;
    boolean searched = !phone.isEmpty() && !"POST".equalsIgnoreCase(request.getMethod());
    if (!phone.isEmpty()) {
        found = customerDAO.getCustomerByPhone(phone);
        if (found != null) foundCard = cardDAO.getCardByCustomer(found.getId());
    }
    List<MembershipCard0> cards = cardDAO.getCardList();
%>
<%@ include file="/common/header.jspf" %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Lập thẻ thành viên</div>
        <h1>Lập thẻ thành viên</h1>
    </div>
</div>
<% if (errors.containsKey("general")) { %><div class="alert err"><%= Format0.h(errors.get("general")) %></div><% } %>
<div class="grid grid-2" style="align-items:start;">
    <div class="card">
        <h3>Tìm khách hàng theo số điện thoại</h3>
        <form class="inline-form" method="get" style="margin-bottom:14px;">
            <div class="form-row" style="flex:1;"><input type="tel" name="phone" value="<%= Format0.h(phone) %>" placeholder="Ví dụ: 0987654321"></div>
            <button class="btn" type="submit">Tìm</button>
        </form>
        <% if (found != null) { %>
            <table class="tbl" style="margin-bottom:12px;">
                <tr><td class="muted">Khách hàng</td><td><b><%= Format0.h(found.getFullName()) %></b> (<%= found.getCode() %>)</td></tr>
                <tr><td class="muted">Điện thoại</td><td><%= Format0.h(found.getPhone()) %></td></tr>
                <tr><td class="muted">Email</td><td><%= Format0.h(found.getEmail()) %></td></tr>
            </table>
            <% if (foundCard != null) { %>
            <div class="alert ok" style="margin-bottom:0;">Đã có thẻ <b><%= foundCard.getCode() %></b> · hạng <%= Format0.h(foundCard.getTier()) %> · <%= foundCard.getPoints() %> điểm · cấp ngày <%= Format0.date(foundCard.getIssueDate()) %></div>
            <% } else { %>
            <form method="post">
                <input type="hidden" name="action" value="issue"><input type="hidden" name="customerId" value="<%= found.getId() %>">
                <button class="btn" type="submit">Lập thẻ thành viên cho khách này</button>
            </form>
            <% } %>
        <% } else if (searched || !errors.isEmpty()) { %>
            <% if (searched) { %><div class="alert warn">Chưa có khách hàng với số điện thoại này. Nhập thông tin để tạo khách hàng và lập thẻ.</div><% } %>
            <form method="post" novalidate>
                <input type="hidden" name="action" value="create">
                <div class="form-row <%= errors.containsKey("fullName") ? "field-error" : "" %>"><label>Họ tên <span class="req">*</span></label>
                    <input type="text" name="fullName" value="<%= Format0.h(request.getParameter("fullName")) %>">
                    <% if (errors.containsKey("fullName")) { %><div class="err-text"><%= errors.get("fullName") %></div><% } %></div>
                <div class="grid grid-2">
                    <div class="form-row <%= errors.containsKey("phone") ? "field-error" : "" %>"><label>Số điện thoại <span class="req">*</span></label>
                        <input type="tel" name="phone" value="<%= Format0.h(phone) %>">
                        <% if (errors.containsKey("phone")) { %><div class="err-text"><%= errors.get("phone") %></div><% } %></div>
                    <div class="form-row <%= errors.containsKey("birthDate") ? "field-error" : "" %>"><label>Ngày sinh</label>
                        <input type="date" name="birthDate" value="<%= Format0.h(request.getParameter("birthDate")) %>">
                        <% if (errors.containsKey("birthDate")) { %><div class="err-text"><%= errors.get("birthDate") %></div><% } %></div>
                </div>
                <div class="form-row <%= errors.containsKey("email") ? "field-error" : "" %>"><label>Email</label>
                    <input type="email" name="email" value="<%= Format0.h(request.getParameter("email")) %>">
                    <% if (errors.containsKey("email")) { %><div class="err-text"><%= errors.get("email") %></div><% } %></div>
                <div class="form-row"><label>Địa chỉ</label><input type="text" name="address" value="<%= Format0.h(request.getParameter("address")) %>"></div>
                <button class="btn" type="submit">Tạo khách hàng và lập thẻ</button>
            </form>
        <% } else { %>
            <p class="muted small" style="margin:0;">Thẻ mới được cấp hạng Bạc (giảm 5%). Mỗi 10.000 đ thanh toán được 1 điểm; từ 100 điểm lên hạng Vàng (giảm 10%).</p>
        <% } %>
    </div>
    <div class="card">
        <h3>Danh sách thẻ thành viên</h3>
        <div class="table-wrap"><table class="tbl">
            <thead><tr><th>Mã thẻ</th><th>Khách hàng</th><th>Điện thoại</th><th>Hạng</th><th class="num">Điểm</th><th>Ngày cấp</th></tr></thead>
            <tbody>
            <% for (MembershipCard0 m : cards) { %>
            <tr><td><%= m.getCode() %></td><td><%= Format0.h(m.getCustomer().getFullName()) %></td><td><%= Format0.h(m.getCustomer().getPhone()) %></td>
                <td><span class="badge <%= "Vàng".equals(m.getTier()) ? "orange" : "" %>"><%= Format0.h(m.getTier()) %></span></td><td class="num"><%= m.getPoints() %></td><td><%= Format0.date(m.getIssueDate()) %></td></tr>
            <% } %>
            </tbody>
        </table></div>
    </div>
</div>
<%@ include file="/common/footer.jspf" %>

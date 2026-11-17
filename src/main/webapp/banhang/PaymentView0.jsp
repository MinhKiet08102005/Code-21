<%-- Thanh toan tai ban: chon don, ap dung the thanh vien, lap hoa don, in hoa don. --%>
<% String REQUIRED_ROLE = "SALE"; String PAGE_TITLE = "Thanh toán tại bàn"; String MENU = "payment"; String SIZE = "l"; %>
<%@ include file="/common/guard.jspf" %>
<%
    OrderDAO0 orderDAO = new OrderDAO0();
    String[] methods = {"Tiền mặt", "Chuyển khoản", "Thẻ ngân hàng", "Ví điện tử"};

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Order0 o = orderDAO.getOrderById(Format0.parseInt(request.getParameter("orderId"), 0));
        String method = request.getParameter("method");
        if (o == null) session.setAttribute("flashErr", "Không tìm thấy đơn gọi món.");
        else if (OrderDAO0.PAID.equals(o.getStatus())) session.setAttribute("flashErr", "Đơn " + o.getCode() + " đã được thanh toán, không thu tiền lần hai.");
        else if (o.getDetails().isEmpty()) session.setAttribute("flashErr", "Đơn chưa có món nào, không thể thanh toán.");
        else if (!Arrays.asList(methods).contains(method)) session.setAttribute("flashErr", "Vui lòng chọn phương thức thanh toán.");
        else {
            Payment0 p = new Payment0();
            p.setOrder(o);
            p.setSaleStaff((SaleStaff0) currentStaff);
            p.setPaymentMethod(method);
            p.setDiscount(BigDecimal.ZERO);
            int customerId = Format0.parseInt(request.getParameter("customerId"), 0);
            if (customerId > 0) {
                Customer0 c = new CustomerDAO0().getCustomerById(customerId);
                p.setCustomer(c);
                MembershipCard0 card = c == null ? null : new MembershipCardDAO0().getCardByCustomer(c.getId());
                if (card != null) p.setDiscount(o.getTotalAmount().multiply(card.getDiscountRate()).setScale(0, java.math.RoundingMode.HALF_UP));
            } else if (o.getCustomer() != null) {
                p.setCustomer(o.getCustomer());
            }
            if (new PaymentDAO0().savePayment(p)) {
                response.sendRedirect(request.getContextPath() + "/banhang/PaymentView0.jsp?paid=" + p.getId());
                return;
            }
            session.setAttribute("flashErr", "Không lưu được hóa đơn, vui lòng thử lại.");
        }
        response.sendRedirect(request.getContextPath() + "/banhang/PaymentView0.jsp" + (o != null ? "?order=" + o.getId() : ""));
        return;
    }

    int paidId = Format0.parseInt(request.getParameter("paid"), 0);
    Payment0 paid = paidId > 0 ? new PaymentDAO0().getPaymentById(paidId) : null;
    Order0 order = paid == null ? orderDAO.getOrderById(Format0.parseInt(request.getParameter("order"), 0)) : null;
    List<Order0> waiting = (paid == null && order == null) ? orderDAO.getOrdersAwaitingPayment() : null;

    // Tra cuu the thanh vien theo so dien thoai
    String phone = Format0.trim(request.getParameter("phone"));
    Customer0 customer = null;
    MembershipCard0 card = null;
    String lookupMsg = null;
    if (order != null) {
        if (!phone.isEmpty()) {
            customer = new CustomerDAO0().getCustomerByPhone(phone);
            if (customer == null) lookupMsg = "Không tìm thấy khách hàng có số điện thoại này.";
        } else if (order.getCustomer() != null) customer = order.getCustomer();
        if (customer != null) {
            card = new MembershipCardDAO0().getCardByCustomer(customer.getId());
            if (card == null) lookupMsg = "Khách hàng chưa có thẻ thành viên, không được giảm giá.";
        }
    }
    BigDecimal discount = (order != null && card != null) ? order.getTotalAmount().multiply(card.getDiscountRate()).setScale(0, java.math.RoundingMode.HALF_UP) : BigDecimal.ZERO;
%>
<%@ include file="/common/header.jspf" %>
<% if (paid != null) { Order0 po = paid.getOrder(); %>
<div class="actions no-print" style="margin-bottom:16px;">
    <button class="btn" onclick="window.print()">In hóa đơn</button>
    <a class="btn secondary" href="<%= ctxPath %>/banhang/PaymentView0.jsp">Thanh toán đơn khác</a>
    <a class="btn secondary" href="<%= ctxPath %>/banhang/SaleHomeView0.jsp">Về trang chủ</a>
</div>
<div class="alert ok no-print">Thanh toán thành công. <%= po.getTable() != null ? "Bàn " + po.getTable().getTableNumber() + " đã được trả về trạng thái trống." : "" %></div>
<div class="print-sheet" style="max-width:560px;">
    <div class="center"><b style="font-size:18px;">NHÀ HÀNG</b><div class="small">123 Nguyễn Huệ, Q.1, TP.HCM · 1900 0021</div></div>
    <h2>HÓA ĐƠN THANH TOÁN</h2>
    <p class="center small" style="margin-top:0;">Số: <b><%= paid.getCode() %></b> · <%= Format0.dateTime(paid.getPaymentTime()) %></p>
    <table style="width:100%; font-size:14px; margin-bottom:10px;">
        <tr><td>Đơn gọi món:</td><td><%= po.getCode() %> <%= po.getTable() != null ? "– Bàn " + po.getTable().getTableNumber() : "– " + po.getOrderType() %></td></tr>
        <tr><td>Thu ngân:</td><td><%= Format0.h(paid.getSaleStaff().getFullName()) %></td></tr>
        <% if (paid.getCustomer() != null) { %><tr><td>Khách hàng:</td><td><%= Format0.h(paid.getCustomer().getFullName()) %> (<%= Format0.h(paid.getCustomer().getPhone()) %>)</td></tr><% } %>
    </table>
    <table class="tbl">
        <thead><tr><th>Món</th><th class="num">SL</th><th class="num">Đơn giá</th><th class="num">Thành tiền</th></tr></thead>
        <tbody>
        <% for (OrderDetail0 d : po.getDetails()) { %>
        <tr><td><%= Format0.h(d.getItemName()) %></td><td class="num"><%= d.getQuantity() %></td><td class="num"><%= Format0.money(d.getUnitPrice()) %></td><td class="num"><%= Format0.money(d.getAmount()) %></td></tr>
        <% } %>
        </tbody>
        <tfoot>
        <tr><td colspan="3">Tổng tiền</td><td class="num"><%= Format0.money(paid.getTotalAmount()) %></td></tr>
        <tr><td colspan="3">Giảm giá thẻ thành viên</td><td class="num">- <%= Format0.money(paid.getDiscount()) %></td></tr>
        <tr><td colspan="3">Khách phải trả (<%= Format0.h(paid.getPaymentMethod()) %>)</td><td class="num" style="font-size:17px;"><%= Format0.money(paid.getFinalAmount()) %></td></tr>
        </tfoot>
    </table>
    <p class="center small muted" style="margin-top:18px;">Cảm ơn quý khách và hẹn gặp lại!</p>
</div>
<% } else if (order != null) { %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Thanh toán tại bàn</div>
        <h1>Thanh toán đơn <%= order.getCode() %> <%= order.getTable() != null ? "– Bàn " + order.getTable().getTableNumber() : "(" + order.getOrderType() + ")" %></h1>
    </div>
    <a class="btn secondary" href="<%= ctxPath %>/banhang/PaymentView0.jsp">Chọn đơn khác</a>
</div>
<% if (OrderDAO0.PAID.equals(order.getStatus())) { %>
<div class="alert err">Đơn này đã được thanh toán, không thể thu tiền lần hai.</div>
<% } else { %>
<div class="grid grid-2" style="align-items:start;">
    <div class="card">
        <h3>Chi tiết đơn</h3>
        <div class="table-wrap"><table class="tbl">
            <thead><tr><th>Món</th><th class="num">SL</th><th class="num">Đơn giá</th><th class="num">Thành tiền</th></tr></thead>
            <tbody>
            <% for (OrderDetail0 d : order.getDetails()) { %>
            <tr><td><%= Format0.h(d.getItemName()) %></td><td class="num"><%= d.getQuantity() %></td><td class="num"><%= Format0.money(d.getUnitPrice()) %></td><td class="num"><%= Format0.money(d.getAmount()) %></td></tr>
            <% } %>
            <% if (order.getDetails().isEmpty()) { %><tr><td colspan="4" class="empty">Đơn chưa có món nào, không thể thanh toán.</td></tr><% } %>
            </tbody>
            <tfoot><tr><td colspan="3">Tổng tiền</td><td class="num"><%= Format0.money(order.getTotalAmount()) %></td></tr></tfoot>
        </table></div>
    </div>
    <div class="card">
        <h3>Thẻ thành viên</h3>
        <form class="inline-form" method="get" style="margin-bottom:10px;">
            <input type="hidden" name="order" value="<%= order.getId() %>">
            <div class="form-row" style="flex:1;"><input type="tel" name="phone" value="<%= Format0.h(phone) %>" placeholder="Số điện thoại khách hàng (nếu có thẻ)"></div>
            <button class="btn secondary" type="submit">Tra cứu</button>
        </form>
        <% if (lookupMsg != null) { %><div class="alert warn"><%= lookupMsg %></div><% } %>
        <% if (card != null) { %>
        <div class="alert ok"><b><%= Format0.h(customer.getFullName()) %></b> · thẻ <%= card.getCode() %> hạng <b><%= Format0.h(card.getTier()) %></b> (<%= card.getPoints() %> điểm) – giảm <%= card.getDiscountRate().movePointRight(2).stripTrailingZeros().toPlainString() %>%</div>
        <% } %>
        <form method="post">
            <input type="hidden" name="orderId" value="<%= order.getId() %>">
            <input type="hidden" name="customerId" value="<%= customer != null ? customer.getId() : 0 %>">
            <table class="tbl" style="margin-bottom:14px;">
                <tr><td>Tổng tiền</td><td class="num"><%= Format0.money(order.getTotalAmount()) %></td></tr>
                <tr><td>Giảm giá</td><td class="num">- <%= Format0.money(discount) %></td></tr>
                <tr><td><b>Khách phải trả</b></td><td class="num" style="font-size:20px; font-weight:700; color:var(--accent);"><%= Format0.money(order.getTotalAmount().subtract(discount)) %></td></tr>
            </table>
            <div class="form-row">
                <label>Phương thức thanh toán</label>
                <select name="method"><% for (String m : methods) { %><option><%= m %></option><% } %></select>
            </div>
            <button class="btn accent" type="submit" <%= order.getDetails().isEmpty() ? "disabled" : "" %>
                    onclick="return confirm('Xác nhận đã thu tiền và lập hóa đơn?');">Xác nhận thanh toán</button>
        </form>
    </div>
</div>
<% } %>
<% } else { %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Thanh toán tại bàn</div>
        <h1>Thanh toán tại bàn</h1>
    </div>
</div>
<div class="card">
    <h3>Các đơn chờ thanh toán</h3>
    <div class="table-wrap"><table class="tbl">
        <thead><tr><th>Mã đơn</th><th>Bàn / loại</th><th>Giờ mở</th><th>Khách hàng</th><th class="num">Số món</th><th class="num">Tổng tiền</th><th></th></tr></thead>
        <tbody>
        <% for (Order0 o : waiting) { %>
        <tr><td><b><%= o.getCode() %></b></td><td><%= o.getTable() != null ? "Bàn " + o.getTable().getTableNumber() : "<span class='badge teal'>" + o.getOrderType() + "</span>" %></td>
            <td><%= Format0.dateTime(o.getOrderTime()) %></td><td><%= o.getCustomer() != null ? Format0.h(o.getCustomer().getFullName()) : "<span class='muted'>Khách vãng lai</span>" %></td>
            <td class="num"><%= o.getDetails().size() %></td><td class="num"><%= Format0.money(o.getTotalAmount()) %></td>
            <td><a class="btn sm" href="?order=<%= o.getId() %>">Thanh toán</a></td></tr>
        <% } %>
        <% if (waiting.isEmpty()) { %><tr><td colspan="7" class="empty">Không có đơn nào chờ thanh toán.</td></tr><% } %>
        </tbody>
    </table></div>
</div>
<% } %>
<%@ include file="/common/footer.jspf" %>

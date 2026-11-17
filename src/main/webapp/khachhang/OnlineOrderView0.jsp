<%-- Khach hang dat mon truc tuyen: gio mon, thong tin nhan, gui don; tra cuu don theo so dien thoai. --%>
<% String PAGE_TITLE = "Đặt món trực tuyến"; String MENU = "order"; String SIZE = "l"; %>
<%
    @SuppressWarnings("unchecked")
    List<OrderDetail0> cart = (List<OrderDetail0>) session.getAttribute("cart");
    if (cart == null) { cart = new ArrayList<>(); session.setAttribute("cart", cart); }
    Map<String, String> errors = new LinkedHashMap<>();
    Order0 placed = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        if ("add".equals(action)) {
            int qty = Math.max(1, Math.min(50, Format0.parseInt(request.getParameter("qty"), 1)));
            int itemId = Format0.parseInt(request.getParameter("itemId"), 0);
            OrderDetail0 line = null;
            if ("combo".equals(request.getParameter("type"))) {
                Combo0 c = new ComboDAO0().getComboById(itemId);
                if (c != null && DishDAO0.AVAILABLE.equals(c.getStatus())) {
                    for (OrderDetail0 l : cart) if (l.getCombo() != null && l.getCombo().getId() == itemId) line = l;
                    if (line == null) { line = new OrderDetail0(); line.setCombo(c); line.setUnitPrice(c.getPrice()); cart.add(line); }
                }
            } else {
                Dish0 d = new DishDAO0().getDishById(itemId);
                if (d != null && DishDAO0.AVAILABLE.equals(d.getStatus())) {
                    for (OrderDetail0 l : cart) if (l.getDish() != null && l.getDish().getId() == itemId) line = l;
                    if (line == null) { line = new OrderDetail0(); line.setDish(d); line.setUnitPrice(d.getSellingPrice()); cart.add(line); }
                }
            }
            if (line != null) {
                line.setQuantity(line.getQuantity() + qty);
                line.calculateAmount();
                session.setAttribute("flashOk", "Đã thêm " + qty + " × " + line.getItemName() + " vào giỏ.");
            } else session.setAttribute("flashErr", "Món này hiện đã ngừng bán.");
            response.sendRedirect(request.getContextPath() + ("menu".equals(request.getParameter("back")) ? "/khachhang/SearchDishView0.jsp" : "/khachhang/OnlineOrderView0.jsp"));
            return;
        } else if ("update".equals(action) || "remove".equals(action)) {
            int idx = Format0.parseInt(request.getParameter("idx"), -1);
            if (idx >= 0 && idx < cart.size()) {
                int qty = Format0.parseInt(request.getParameter("qty"), 0);
                if ("remove".equals(action) || qty <= 0) cart.remove(idx);
                else { cart.get(idx).setQuantity(Math.min(qty, 50)); cart.get(idx).calculateAmount(); }
            }
            response.sendRedirect(request.getContextPath() + "/khachhang/OnlineOrderView0.jsp");
            return;
        } else if ("submit".equals(action)) {
            String fullName = Format0.trim(request.getParameter("fullName"));
            String phone = Format0.trim(request.getParameter("phone"));
            String email = request.getParameter("email");
            if (cart.isEmpty()) errors.put("general", "Giỏ món đang trống, vui lòng chọn món trước khi đặt.");
            if (fullName.isEmpty()) errors.put("fullName", "Vui lòng nhập họ tên");
            if (!Format0.validPhone(phone)) errors.put("phone", "Số điện thoại phải gồm 10 chữ số, bắt đầu bằng 0");
            if (!Format0.validEmail(email)) errors.put("email", "Email không đúng định dạng");
            if (errors.isEmpty()) {
                Customer0 c = new CustomerDAO0().getOrCreateCustomer(fullName, phone, email);
                Order0 o = new Order0();
                o.setCustomer(c);
                o.setNote(Format0.nullIfBlank(request.getParameter("note")));
                for (OrderDetail0 l : cart) {
                    OrderDetail0 d = new OrderDetail0();
                    d.setDish(l.getDish());
                    d.setCombo(l.getCombo());
                    d.setQuantity(l.getQuantity());
                    d.setUnitPrice(l.getUnitPrice());
                    o.getDetails().add(d);
                }
                if (c != null && new OrderDAO0().addOnlineOrder(o)) {
                    placed = new OrderDAO0().getOrderById(o.getId());
                    cart.clear();
                } else errors.put("general", "Không gửi được đơn, vui lòng thử lại.");
            }
        }
    }
    BigDecimal total = BigDecimal.ZERO;
    for (OrderDetail0 l : cart) total = total.add(l.getAmount());
    String lookup = Format0.trim(request.getParameter("lookup"));
    List<Order0> mine = lookup.isEmpty() ? null : new OrderDAO0().getOrdersByPhone(lookup);
%>
<%@ include file="/common/header_public.jspf" %>
<% if (placed != null) { %>
<div class="result-box">
    <div class="big-ico ok">✓</div>
    <h2>Đã gửi đơn đặt món – Mã đơn: <%= placed.getCode() %></h2>
    <p class="muted"><%= placed.getDetails().size() %> món · tổng <b><%= Format0.money(placed.getTotalAmount()) %></b><br>
        Trạng thái: <b><%= placed.getStatus() %></b>. Nhân viên nhà hàng sẽ xác nhận đơn; bạn có thể tra cứu bằng số điện thoại.</p>
    <div class="actions" style="justify-content:center;">
        <a class="btn" href="<%= ctxPath %>/khachhang/OnlineOrderView0.jsp?lookup=<%= placed.getCustomer().getPhone() %>">Xem trạng thái đơn</a>
        <a class="btn secondary" href="<%= ctxPath %>/khachhang/SearchDishView0.jsp">Tiếp tục xem thực đơn</a>
    </div>
</div>
<% } else { %>
<div class="page-head"><div><h1>Đặt món trực tuyến</h1><div class="muted">Chọn món ở trang <a href="<%= ctxPath %>/khachhang/SearchDishView0.jsp">Thực đơn</a>, kiểm tra giỏ món và gửi đơn.</div></div></div>
<% if (errors.containsKey("general")) { %><div class="alert err"><%= errors.get("general") %></div><% } %>
<div class="grid grid-2" style="align-items:start;">
    <div class="card">
        <h3>Giỏ món của bạn</h3>
        <div class="table-wrap"><table class="tbl">
            <thead><tr><th>Món</th><th class="num">Đơn giá</th><th>Số lượng</th><th class="num">Thành tiền</th><th></th></tr></thead>
            <tbody>
            <% for (int i = 0; i < cart.size(); i++) { OrderDetail0 l = cart.get(i); %>
            <tr><td><%= Format0.h(l.getItemName()) %></td><td class="num"><%= Format0.money(l.getUnitPrice()) %></td>
                <td><form method="post" style="margin:0;"><input type="hidden" name="action" value="update"><input type="hidden" name="idx" value="<%= i %>">
                    <input class="qty-input" type="number" name="qty" value="<%= l.getQuantity() %>" min="0" max="50" onchange="this.form.submit()"></form></td>
                <td class="num"><%= Format0.money(l.getAmount()) %></td>
                <td><form method="post" style="margin:0;"><input type="hidden" name="action" value="remove"><input type="hidden" name="idx" value="<%= i %>"><button class="btn link danger" type="submit">Xóa</button></form></td></tr>
            <% } %>
            <% if (cart.isEmpty()) { %><tr><td colspan="5" class="empty">Giỏ món trống. <a href="<%= ctxPath %>/khachhang/SearchDishView0.jsp">Chọn món</a></td></tr><% } %>
            </tbody>
            <tfoot><tr><td colspan="3">Tổng tiền</td><td class="num"><%= Format0.money(total) %></td><td></td></tr></tfoot>
        </table></div>
    </div>
    <div class="card">
        <h3>Thông tin người đặt</h3>
        <form method="post" novalidate>
            <input type="hidden" name="action" value="submit">
            <div class="form-row <%= errors.containsKey("fullName") ? "field-error" : "" %>"><label>Họ tên <span class="req">*</span></label>
                <input type="text" name="fullName" value="<%= Format0.h(request.getParameter("fullName")) %>">
                <% if (errors.containsKey("fullName")) { %><div class="err-text"><%= errors.get("fullName") %></div><% } %></div>
            <div class="grid grid-2">
                <div class="form-row <%= errors.containsKey("phone") ? "field-error" : "" %>"><label>Số điện thoại <span class="req">*</span></label>
                    <input type="tel" name="phone" value="<%= Format0.h(request.getParameter("phone")) %>" maxlength="10">
                    <% if (errors.containsKey("phone")) { %><div class="err-text"><%= errors.get("phone") %></div><% } %></div>
                <div class="form-row <%= errors.containsKey("email") ? "field-error" : "" %>"><label>Email</label>
                    <input type="email" name="email" value="<%= Format0.h(request.getParameter("email")) %>">
                    <% if (errors.containsKey("email")) { %><div class="err-text"><%= errors.get("email") %></div><% } %></div>
            </div>
            <div class="form-row"><label>Ghi chú</label><textarea name="note" maxlength="500" placeholder="Ví dụ: đến lấy lúc 12 giờ, ít cay..."><%= Format0.h(request.getParameter("note")) %></textarea></div>
            <button class="btn" type="submit" <%= cart.isEmpty() ? "disabled" : "" %>>Gửi đơn đặt món</button>
        </form>
        <hr style="border:none; border-top:1px solid var(--line); margin:20px 0;">
        <h3>Tra cứu đơn đã đặt</h3>
        <form class="inline-form" method="get" style="margin-bottom:10px;">
            <div class="form-row" style="flex:1;"><input type="tel" name="lookup" value="<%= Format0.h(lookup) %>" placeholder="Số điện thoại"></div>
            <button class="btn secondary" type="submit">Tra cứu</button>
        </form>
        <% if (mine != null) { %>
            <% if (mine.isEmpty()) { %><div class="empty">Không có đơn nào với số điện thoại này.</div><% } else { %>
            <table class="tbl"><thead><tr><th>Mã đơn</th><th>Thời gian</th><th class="num">Tổng</th><th>Trạng thái</th></tr></thead><tbody>
            <% for (Order0 o : mine) { String st = o.getStatus(); %>
            <tr><td><%= o.getCode() %><div class="small muted"><%= o.getOrderType() %></div></td><td><%= Format0.dateTime(o.getOrderTime()) %></td><td class="num"><%= Format0.money(o.getTotalAmount()) %></td>
                <td><span class="badge <%= OrderDAO0.REJECTED.equals(st) ? "red" : OrderDAO0.PENDING.equals(st) ? "orange" : "green" %>"><%= Format0.h(st) %></span></td></tr>
            <% } %>
            </tbody></table>
            <% } %>
        <% } %>
    </div>
</div>
<% } %>
<%@ include file="/common/footer_public.jspf" %>

<%-- Xem thong ke: mon an, nguyen lieu, khach hang, nha cung cap theo khoang thoi gian. --%>
<% String REQUIRED_ROLE = "MANAGER"; String PAGE_TITLE = "Xem thống kê"; String MENU = "stat"; String SIZE = "l"; %>
<%@ include file="/common/guard.jspf" %>
<%
    String type = request.getParameter("type");
    if (type == null || !Arrays.asList("dish", "ingredient", "customer", "supplier").contains(type)) type = "dish";
    LocalDate today = LocalDate.now();
    LocalDate from, to;
    String error = null;
    try {
        from = Format0.blank(request.getParameter("from")) ? today.minusMonths(1).withDayOfMonth(1) : LocalDate.parse(request.getParameter("from"));
        to = Format0.blank(request.getParameter("to")) ? today : LocalDate.parse(request.getParameter("to"));
    } catch (Exception e) {
        from = today.minusMonths(1).withDayOfMonth(1);
        to = today;
        error = "Ngày không đúng định dạng, đã dùng khoảng thời gian mặc định.";
    }
    boolean valid = !from.isAfter(to);
    if (!valid) error = "Khoảng thời gian không hợp lệ: ngày bắt đầu phải trước hoặc bằng ngày kết thúc.";
    StatisticDAO0 dao = new StatisticDAO0();
    String period = "from=" + from + "&to=" + to;
    int sid = Format0.parseInt(request.getParameter("sid"), 0);
    String[][] tabs = {{"dish", "Thống kê món ăn"}, {"ingredient", "Thống kê nguyên liệu"}, {"customer", "Thống kê khách hàng"}, {"supplier", "Thống kê nhà cung cấp"}};
%>
<%@ include file="/common/header.jspf" %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Xem thống kê</div>
        <h1>Xem thống kê</h1>
    </div>
</div>
<div class="tabs">
    <% for (String[] t : tabs) { %>
    <a href="?type=<%= t[0] %>&<%= period %>" class="<%= t[0].equals(type) ? "active" : "" %>"><%= t[1] %></a>
    <% } %>
</div>
<div class="card">
    <form class="inline-form" method="get">
        <input type="hidden" name="type" value="<%= type %>">
        <div class="form-row"><label>Ngày bắt đầu</label><input type="date" name="from" value="<%= from %>"></div>
        <div class="form-row"><label>Ngày kết thúc</label><input type="date" name="to" value="<%= to %>"></div>
        <button class="btn" type="submit">Thống kê</button>
        <span class="muted small">Từ <%= Format0.date(from) %> đến <%= Format0.date(to) %></span>
    </form>
</div>
<% if (error != null) { %><div class="alert <%= valid ? "warn" : "err" %>"><%= error %></div><% } %>
<% if (valid) { %>
<%  if ("dish".equals(type)) {
        List<DishStat0> list = dao.getDishStatistic(from, to);
        BigDecimal total = BigDecimal.ZERO, max = BigDecimal.ONE; int qty = 0;
        for (DishStat0 s : list) { total = total.add(s.getRevenue()); qty += s.getQuantitySold(); if (s.getRevenue().compareTo(max) > 0) max = s.getRevenue(); }
        BigDecimal[] sum = dao.getRevenueSummary(from, to); %>
<div class="grid grid-3" style="margin-bottom:18px;">
    <div class="stat"><div class="label">Doanh thu (sau giảm giá)</div><div class="value"><%= Format0.money(sum[0]) %></div></div>
    <div class="stat"><div class="label">Số hóa đơn</div><div class="value"><%= sum[1].intValue() %></div></div>
    <div class="stat"><div class="label">Số phần món gọi lẻ đã bán</div><div class="value"><%= qty %></div></div>
</div>
<div class="card">
    <h3>Món ăn bán được, xếp theo doanh thu</h3>
    <div class="table-wrap"><table class="tbl">
        <thead><tr><th>TT</th><th>Mã món</th><th>Tên món</th><th>Danh mục</th><th class="num">Giá bán</th><th class="num">Số lượng bán</th><th class="num">Doanh thu</th><th style="width:22%"></th></tr></thead>
        <tbody>
        <% int i = 0; for (DishStat0 s : list) { i++; %>
        <tr><td><%= i %></td><td><%= s.getCode() %></td><td><b><%= Format0.h(s.getName()) %></b></td><td><%= Format0.h(s.getCategory().getName()) %></td>
            <td class="num"><%= Format0.money(s.getSellingPrice()) %></td><td class="num"><%= s.getQuantitySold() %></td><td class="num"><%= Format0.money(s.getRevenue()) %></td>
            <td><div style="height:8px;border-radius:4px;background:var(--primary);width:<%= s.getRevenue().multiply(BigDecimal.valueOf(100)).divide(max, 0, java.math.RoundingMode.HALF_UP) %>%"></div></td></tr>
        <% } %>
        <% if (list.isEmpty()) { %><tr><td colspan="8" class="empty">Không có món nào được bán trong khoảng thời gian này.</td></tr><% } %>
        </tbody>
        <% if (!list.isEmpty()) { %><tfoot><tr><td colspan="5">Tổng</td><td class="num"><%= qty %></td><td class="num"><%= Format0.money(total) %></td><td></td></tr></tfoot><% } %>
    </table></div>
    <p class="small muted" style="margin-bottom:0;">Chỉ tính các món gọi lẻ; combo được tính vào doanh thu chung ở trên.</p>
</div>
<%  } else if ("ingredient".equals(type)) {
        List<IngredientStat0> list = dao.getIngredientStatistic(from, to);
        BigDecimal total = BigDecimal.ZERO; int low = 0;
        for (IngredientStat0 s : list) { total = total.add(s.getImportValue()); if (s.getStockQuantity().compareTo(BigDecimal.valueOf(5)) < 0) low++; } %>
<div class="grid grid-3" style="margin-bottom:18px;">
    <div class="stat"><div class="label">Tổng giá trị nhập</div><div class="value"><%= Format0.money(total) %></div></div>
    <div class="stat"><div class="label">Số loại nguyên liệu</div><div class="value"><%= list.size() %></div></div>
    <div class="stat"><div class="label">Sắp hết (tồn dưới 5)</div><div class="value"><%= low %></div></div>
</div>
<div class="card">
    <h3>Nguyên liệu nhập trong kỳ và tồn kho hiện tại</h3>
    <div class="table-wrap"><table class="tbl">
        <thead><tr><th>TT</th><th>Mã</th><th>Tên nguyên liệu</th><th>Đơn vị</th><th class="num">Số lần nhập</th><th class="num">Số lượng nhập</th><th class="num">Giá trị nhập</th><th class="num">Tồn kho</th></tr></thead>
        <tbody>
        <% int i = 0; for (IngredientStat0 s : list) { i++; boolean isLow = s.getStockQuantity().compareTo(BigDecimal.valueOf(5)) < 0; %>
        <tr><td><%= i %></td><td><%= s.getCode() %></td><td><b><%= Format0.h(s.getName()) %></b></td><td><%= Format0.h(s.getUnit()) %></td>
            <td class="num"><%= s.getInvoiceCount() %></td><td class="num"><%= Format0.qty(s.getImportQuantity()) %></td><td class="num"><%= Format0.money(s.getImportValue()) %></td>
            <td class="num"><%= Format0.qty(s.getStockQuantity()) %> <% if (isLow) { %><span class="badge orange">sắp hết</span><% } %></td></tr>
        <% } %>
        </tbody>
        <tfoot><tr><td colspan="6">Tổng giá trị nhập</td><td class="num"><%= Format0.money(total) %></td><td></td></tr></tfoot>
    </table></div>
</div>
<%  } else if ("customer".equals(type)) {
        List<CustomerStat0> list = dao.getCustomerStatistic(from, to);
        BigDecimal total = BigDecimal.ZERO;
        for (CustomerStat0 s : list) total = total.add(s.getTotalSpent()); %>
<div class="card">
    <h3>Khách hàng (có thông tin khi thanh toán), xếp theo tổng chi tiêu</h3>
    <div class="table-wrap"><table class="tbl">
        <thead><tr><th>TT</th><th>Mã KH</th><th>Họ tên</th><th>Số điện thoại</th><th class="num">Số lần thanh toán</th><th class="num">Tổng chi tiêu</th></tr></thead>
        <tbody>
        <% int i = 0; for (CustomerStat0 s : list) { i++; %>
        <tr><td><%= i %></td><td><%= s.getCode() %></td><td><b><%= Format0.h(s.getFullName()) %></b></td><td><%= Format0.h(s.getPhone()) %></td>
            <td class="num"><%= s.getVisitCount() %></td><td class="num"><%= Format0.money(s.getTotalSpent()) %></td></tr>
        <% } %>
        <% if (list.isEmpty()) { %><tr><td colspan="6" class="empty">Không có dữ liệu trong khoảng thời gian này.</td></tr><% } %>
        </tbody>
        <% if (!list.isEmpty()) { %><tfoot><tr><td colspan="5">Tổng</td><td class="num"><%= Format0.money(total) %></td></tr></tfoot><% } %>
    </table></div>
</div>
<%  } else {
        List<SupplierStat0> list = dao.getSupplierStatistic(from, to);
        BigDecimal total = BigDecimal.ZERO;
        for (SupplierStat0 s : list) total = total.add(s.getTotalImport()); %>
<div class="card">
    <h3>Nhà cung cấp, xếp theo tổng giá trị nhập</h3>
    <div class="table-wrap"><table class="tbl">
        <thead><tr><th>TT</th><th>Mã NCC</th><th>Tên nhà cung cấp</th><th>Điện thoại</th><th class="num">Số phiếu nhập</th><th class="num">Tổng giá trị nhập</th><th></th></tr></thead>
        <tbody>
        <% int i = 0; for (SupplierStat0 s : list) { i++; %>
        <tr class="<%= s.getId() == sid ? "highlight" : "" %>"><td><%= i %></td><td><%= s.getCode() %></td><td><b><%= Format0.h(s.getName()) %></b></td><td><%= Format0.h(s.getPhone()) %></td>
            <td class="num"><%= s.getInvoiceCount() %></td><td class="num"><%= Format0.money(s.getTotalImport()) %></td>
            <td><% if (s.getInvoiceCount() > 0) { %><a href="?type=supplier&<%= period %>&sid=<%= s.getId() %>">Xem phiếu nhập</a><% } %></td></tr>
        <% } %>
        </tbody>
        <tfoot><tr><td colspan="5">Tổng</td><td class="num"><%= Format0.money(total) %></td><td></td></tr></tfoot>
    </table></div>
</div>
<%      if (sid > 0) {
            Supplier0 sup = new SupplierDAO0().getSupplierById(sid);
            List<ImportInvoice0> invs = new ImportInvoiceDAO0().getInvoiceList(sid, from.atStartOfDay(), to.plusDays(1).atStartOfDay()); %>
<div class="card">
    <h3>Phiếu nhập của <%= Format0.h(sup == null ? "" : sup.getName()) %></h3>
    <div class="table-wrap"><table class="tbl">
        <thead><tr><th>TT</th><th>Mã phiếu</th><th>Ngày nhập</th><th>Nhân viên kho lập phiếu</th><th class="num">Tổng tiền</th><th></th></tr></thead>
        <tbody>
        <% int j = 0; for (ImportInvoice0 inv : invs) { j++; %>
        <tr><td><%= j %></td><td><%= inv.getCode() %></td><td><%= Format0.dateTime(inv.getImportDate()) %></td><td><%= Format0.h(inv.getWarehouseStaff().getFullName()) %></td>
            <td class="num"><%= Format0.money(inv.getTotalAmount()) %></td>
            <td><a href="<%= ctxPath %>/kho/PrintImportInvoiceView0.jsp?id=<%= inv.getId() %>">Xem chi tiết</a></td></tr>
        <% } %>
        </tbody>
    </table></div>
</div>
<%      }
    } %>
<% } %>
<%@ include file="/common/footer.jspf" %>

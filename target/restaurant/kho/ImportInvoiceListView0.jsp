<%-- Danh sach phieu nhap da luu: xem lai, in lai. --%>
<% String REQUIRED_ROLE = "WAREHOUSE"; String PAGE_TITLE = "Danh sách phiếu nhập"; String MENU = "invoices"; String SIZE = "m"; %>
<%@ include file="/common/guard.jspf" %>
<%
    int sid = Format0.parseInt(request.getParameter("sid"), 0);
    List<ImportInvoice0> list = new ImportInvoiceDAO0().getInvoiceList(sid, null, null);
    List<Supplier0> suppliers = new SupplierDAO0().searchSupplier("");
    BigDecimal total = BigDecimal.ZERO;
    for (ImportInvoice0 inv : list) total = total.add(inv.getTotalAmount());
%>
<%@ include file="/common/header.jspf" %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Danh sách phiếu nhập</div>
        <h1>Danh sách phiếu nhập</h1>
    </div>
    <a class="btn" href="<%= ctxPath %>/kho/SearchSupplierView0.jsp?mode=import">+ Lập phiếu nhập mới</a>
</div>
<div class="card">
    <form class="inline-form" method="get" style="margin-bottom:14px;">
        <div class="form-row" style="width:300px;">
            <label>Nhà cung cấp</label>
            <select name="sid" onchange="this.form.submit()">
                <option value="0">Tất cả</option>
                <% for (Supplier0 s : suppliers) { %><option value="<%= s.getId() %>" <%= s.getId() == sid ? "selected" : "" %>><%= Format0.h(s.getName()) %></option><% } %>
            </select>
        </div>
    </form>
    <div class="table-wrap"><table class="tbl">
        <thead><tr><th>TT</th><th>Mã phiếu</th><th>Ngày nhập</th><th>Nhà cung cấp</th><th>Nhân viên lập</th><th class="num">Tổng tiền</th><th></th></tr></thead>
        <tbody>
        <% int i = 0; for (ImportInvoice0 inv : list) { i++; %>
        <tr><td><%= i %></td><td><b><%= inv.getCode() %></b></td><td><%= Format0.dateTime(inv.getImportDate()) %></td><td><%= Format0.h(inv.getSupplier().getName()) %></td>
            <td><%= Format0.h(inv.getWarehouseStaff().getFullName()) %></td><td class="num"><%= Format0.money(inv.getTotalAmount()) %></td>
            <td><a class="btn sm secondary" href="<%= ctxPath %>/kho/PrintImportInvoiceView0.jsp?id=<%= inv.getId() %>">Xem / In lại</a></td></tr>
        <% } %>
        <% if (list.isEmpty()) { %><tr><td colspan="7" class="empty">Chưa có phiếu nhập.</td></tr><% } %>
        </tbody>
        <tfoot><tr><td colspan="5">Tổng</td><td class="num"><%= Format0.money(total) %></td><td></td></tr></tfoot>
    </table></div>
</div>
<%@ include file="/common/footer.jspf" %>

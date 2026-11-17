<%-- In phieu nhap: in chung tu tu phieu da duoc xac nhan va luu. In loi thi in lai cung phieu nay. --%>
<% String REQUIRED_ROLE = "WAREHOUSE,MANAGER"; String PAGE_TITLE = "Phiếu nhập kho"; String MENU = "invoices"; String SIZE = "m"; %>
<%@ include file="/common/guard.jspf" %>
<%
    ImportInvoiceDAO0 dao = new ImportInvoiceDAO0();
    int id = Format0.parseInt(request.getParameter("id"), 0);
    if (!dao.printInvoice(id)) {
        session.setAttribute("flashErr", "Không tìm thấy phiếu nhập.");
        response.sendRedirect(request.getContextPath() + ("MANAGER".equals(currentStaff.getRole()) ? "/quanly/StatisticView0.jsp?type=supplier" : "/kho/ImportInvoiceListView0.jsp"));
        return;
    }
    ImportInvoice0 inv = dao.getInvoiceById(id);
    boolean manager = "MANAGER".equals(currentStaff.getRole());
%>
<%@ include file="/common/header.jspf" %>
<div class="actions no-print" style="margin-bottom:16px;">
    <button class="btn" onclick="window.print()">In phiếu nhập</button>
    <a class="btn secondary" href="javascript:history.back()">Quay lại</a>
    <span class="muted small">Nếu máy in gặp lỗi, phiếu vẫn đã được lưu; có thể bấm In lại bất cứ lúc nào.</span>
</div>
<div class="print-sheet">
    <div class="sheet-head">
        <div><b>NHÀ HÀNG</b><div class="small">123 Nguyễn Huệ, Q.1, TP.HCM</div></div>
        <div class="right small">Mã phiếu: <b><%= inv.getCode() %></b><br>Ngày nhập: <%= Format0.dateTime(inv.getImportDate()) %></div>
    </div>
    <h2>PHIẾU NHẬP KHO</h2>
    <p class="center muted small" style="margin-top:0;">Kiêm chứng từ thanh toán cho nhà cung cấp</p>
    <table style="width:100%; margin: 12px 0 16px; font-size:14px;">
        <tr><td style="width:24%;">Nhà cung cấp:</td><td><b><%= Format0.h(inv.getSupplier().getName()) %></b> (<%= inv.getSupplier().getCode() %>)</td></tr>
        <tr><td>Địa chỉ:</td><td><%= Format0.h(inv.getSupplier().getAddress()) %></td></tr>
        <tr><td>Điện thoại:</td><td><%= Format0.h(inv.getSupplier().getPhone()) %></td></tr>
        <tr><td>Nhân viên kho lập phiếu:</td><td><%= Format0.h(inv.getWarehouseStaff().getFullName()) %></td></tr>
    </table>
    <table class="tbl" style="border:1px solid var(--line);">
        <thead><tr><th>TT</th><th>Mã NL</th><th>Tên nguyên liệu</th><th>ĐVT</th><th class="num">Số lượng</th><th class="num">Đơn giá</th><th class="num">Thành tiền</th></tr></thead>
        <tbody>
        <% int i = 0; for (ImportDetail0 d : inv.getDetails()) { i++; %>
        <tr><td><%= i %></td><td><%= d.getIngredient().getCode() %></td><td><%= Format0.h(d.getIngredient().getName()) %></td><td><%= Format0.h(d.getIngredient().getUnit()) %></td>
            <td class="num"><%= Format0.qty(d.getQuantity()) %></td><td class="num"><%= Format0.money(d.getUnitPrice()) %></td><td class="num"><%= Format0.money(d.getAmount()) %></td></tr>
        <% } %>
        </tbody>
        <tfoot><tr><td colspan="6">Tổng tiền thanh toán</td><td class="num"><%= Format0.money(inv.getTotalAmount()) %></td></tr></tfoot>
    </table>
    <div class="sign">
        <div><b>Người giao hàng</b><div class="small muted">(ký, ghi rõ họ tên)</div></div>
        <div><b>Nhân viên kho</b><div class="small muted">(ký, ghi rõ họ tên)</div><br><br><%= Format0.h(inv.getWarehouseStaff().getFullName()) %></div>
    </div>
</div>
<% if ("1".equals(request.getParameter("autoprint")) && !manager) { %>
<script>window.addEventListener('load', function () { setTimeout(function () { window.print(); }, 300); });</script>
<% } %>
<%@ include file="/common/footer.jspf" %>

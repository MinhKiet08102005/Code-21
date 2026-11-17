<%-- Luu phieu nhap. Thiet ke: -invoice : ImportInvoice0, -listDetail : ImportDetail0[], -message : String.
     Phu thuoc ImportInvoiceDAO0 (luu phieu + chi tiet + cong ton kho trong mot giao dich). --%>
<% String REQUIRED_ROLE = "WAREHOUSE"; String PAGE_TITLE = "Thông báo"; String MENU = "import"; String SIZE = "s"; %>
<%@ include file="/common/guard.jspf" %>
<%
    Supplier0 supplier = (Supplier0) session.getAttribute("importSupplier");
    @SuppressWarnings("unchecked")
    List<ImportDetail0> listDetail = (List<ImportDetail0>) session.getAttribute("importDetails");
    if (!"POST".equalsIgnoreCase(request.getMethod()) || supplier == null || listDetail == null || listDetail.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/kho/ImportIngredientView0.jsp");
        return;
    }
    ImportInvoice0 invoice = new ImportInvoice0();
    invoice.setSupplier(supplier);
    invoice.setWarehouseStaff((WarehouseStaff0) currentStaff);
    invoice.setDetails(new ArrayList<>(listDetail));
    boolean ok = new ImportInvoiceDAO0().saveImportInvoice(invoice);
    String message;
    if (ok) {
        session.removeAttribute("importSupplier");
        session.removeAttribute("importDetails");
        message = "Nhập kho thành công – Mã phiếu: " + invoice.getCode();
    } else {
        message = "Không lưu được phiếu nhập. Phiếu chưa được lưu và tồn kho không thay đổi, vui lòng thực hiện lại.";
    }
%>
<%@ include file="/common/header.jspf" %>
<% if (ok) { %>
<p class="line">Nhập kho thành công.</p>
<p class="line">Mã phiếu nhập: <%= invoice.getCode() %></p>
<p class="line">Sau khi in hóa đơn, nhân viên kho thanh toán trực tiếp cho nhà cung cấp theo tổng tiền trên hóa đơn.</p>
<p class="line muted small"><%= Format0.h(supplier.getName()) %> · <%= invoice.getDetails().size() %> nguyên liệu · <%= Format0.money(invoice.getTotalAmount()) %>. Tồn kho đã được cập nhật.</p>
<div class="actions">
    <a class="btn" href="<%= ctxPath %>/kho/PrintImportInvoiceView0.jsp?id=<%= invoice.getId() %>&autoprint=1">In hóa đơn</a>
    <a class="btn" href="<%= ctxPath %>/kho/WarehouseHomeView0.jsp">OK</a>
</div>
<% } else { %>
<p class="line">Nhập kho không thành công.</p>
<p class="line"><%= Format0.h(message) %></p>
<div class="actions"><a class="btn" href="<%= ctxPath %>/kho/ConfirmImportView0.jsp">Quay lại</a></div>
<% } %>
<%@ include file="/common/footer.jspf" %>

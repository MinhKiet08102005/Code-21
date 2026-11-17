<%-- Xac nhan phieu nhap. Thiet ke: -supplier : Supplier0, -lblTotalItem : Label, -lblTotalAmount : Label, -btnConfirmPrint, -btnBack --%>
<% String REQUIRED_ROLE = "WAREHOUSE"; String PAGE_TITLE = "Xác nhận phiếu nhập"; String MENU = "import"; String SIZE = "s"; %>
<%@ include file="/common/guard.jspf" %>
<%
    Supplier0 supplier = (Supplier0) session.getAttribute("importSupplier");
    @SuppressWarnings("unchecked")
    List<ImportDetail0> listDetail = (List<ImportDetail0>) session.getAttribute("importDetails");
    if (supplier == null || listDetail == null || listDetail.isEmpty()) {
        session.setAttribute("flashErr", "Vui lòng thêm ít nhất một nguyên liệu.");
        response.sendRedirect(request.getContextPath() + "/kho/ImportIngredientView0.jsp");
        return;
    }
    BigDecimal total = new ImportInvoiceDAO0().calculateTotal(listDetail);
%>
<%@ include file="/common/header.jspf" %>
<div class="info-rows">
    <div>Nhà cung cấp:</div><div><%= Format0.h(supplier.getName()) %></div>
    <div>Nhân viên nhập:</div><div><%= Format0.h(currentStaff.getFullName()) %></div>
    <div>Tổng số mặt hàng:</div><div><%= listDetail.size() %></div>
    <div>Tổng tiền:</div><div><%= Format0.money(total) %></div>
</div>
<form method="post" action="<%= ctxPath %>/kho/doSaveImport0.jsp" class="actions">
    <button class="btn" type="submit" name="btnConfirmPrint">Xác nhận và In hóa đơn</button>
    <a class="btn" href="<%= ctxPath %>/kho/ImportIngredientView0.jsp">Quay lại</a>
</form>
<p class="note">Đối chiếu với hàng thực nhận. Nếu hàng giao thiếu hoặc không đạt chất lượng, bấm Quay lại và sửa số lượng theo phần thực nhận.</p>
<%@ include file="/common/footer.jspf" %>

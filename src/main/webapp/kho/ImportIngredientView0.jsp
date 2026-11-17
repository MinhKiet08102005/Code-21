<%-- Lap phieu nhap nguyen lieu. Thiet ke: -supplier : Supplier0, -txtIngredientName : TextBox, -btnSearch : submit,
     -listIngredient : Ingredient0[], -tblIngredient : Table, -listDetail : ImportDetail0[], -tblDetail : Table,
     -lblTotalAmount : Label, -lnkDeleteRow : link, -btnAddIngredient, -btnConfirm, -btnCancel : submit --%>
<% String REQUIRED_ROLE = "WAREHOUSE"; String PAGE_TITLE = "Lập phiếu nhập nguyên liệu"; String MENU = "import"; String SIZE = "l"; %>
<%@ include file="/common/guard.jspf" %>
<%
    // Chon nha cung cap moi -> bat dau phieu moi
    int supplierId = Format0.parseInt(request.getParameter("supplierId"), 0);
    if (supplierId > 0) {
        Supplier0 chosen = new SupplierDAO0().getSupplierById(supplierId);
        if (chosen != null) {
            Supplier0 old = (Supplier0) session.getAttribute("importSupplier");
            if (old == null || old.getId() != chosen.getId()) session.setAttribute("importDetails", new ArrayList<ImportDetail0>());
            session.setAttribute("importSupplier", chosen);
        }
        response.sendRedirect(request.getContextPath() + "/kho/ImportIngredientView0.jsp");
        return;
    }
    Supplier0 supplier = (Supplier0) session.getAttribute("importSupplier");
    if (supplier == null) {
        session.setAttribute("flashErr", "Vui lòng chọn nhà cung cấp trước khi lập phiếu nhập.");
        response.sendRedirect(request.getContextPath() + "/kho/SearchSupplierView0.jsp?mode=import");
        return;
    }
    @SuppressWarnings("unchecked")
    List<ImportDetail0> listDetail = (List<ImportDetail0>) session.getAttribute("importDetails");
    if (listDetail == null) { listDetail = new ArrayList<>(); session.setAttribute("importDetails", listDetail); }

    String action = request.getParameter("action");
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if ("remove".equals(action)) {
            int idx = Format0.parseInt(request.getParameter("idx"), -1);
            if (idx >= 0 && idx < listDetail.size()) {
                session.setAttribute("flashOk", "Đã xóa " + listDetail.get(idx).getIngredient().getName() + " khỏi phiếu.");
                listDetail.remove(idx);
            }
        } else if ("cancel".equals(action)) {
            session.removeAttribute("importSupplier");
            session.removeAttribute("importDetails");
            session.setAttribute("flashOk", "Đã hủy phiếu nhập. Phiếu không được lưu, tồn kho không thay đổi.");
            response.sendRedirect(request.getContextPath() + "/kho/WarehouseHomeView0.jsp");
            return;
        } else if ("confirm".equals(action)) {
            if (listDetail.isEmpty()) session.setAttribute("flashErr", "Vui lòng thêm ít nhất một nguyên liệu.");
            else { response.sendRedirect(request.getContextPath() + "/kho/ConfirmImportView0.jsp"); return; }
        }
        response.sendRedirect(request.getContextPath() + "/kho/ImportIngredientView0.jsp");
        return;
    }

    String txtIngredientName = request.getParameter("txtIngredientName");
    List<Ingredient0> listIngredient = txtIngredientName == null ? null : new IngredientDAO0().searchIngredient(txtIngredientName);
    BigDecimal total = new ImportInvoiceDAO0().calculateTotal(listDetail);
    Set<Integer> inList = new HashSet<>();
    for (ImportDetail0 d : listDetail) inList.add(d.getIngredient().getId());
%>
<%@ include file="/common/header.jspf" %>
<p class="line">Nhà cung cấp: <%= Format0.h(supplier.getName()) %> (<%= supplier.getCode() %>)
    <a class="small" style="margin-left:10px;" href="<%= ctxPath %>/kho/SearchSupplierView0.jsp?mode=import">Đổi nhà cung cấp</a></p>
<form method="get" class="inline-form">
    <div class="form-row">
        <label for="txtIngredientName">Tên nguyên liệu:</label>
        <input type="text" id="txtIngredientName" name="txtIngredientName" value="<%= Format0.h(txtIngredientName) %>" autofocus>
    </div>
    <button class="btn" type="submit" name="btnSearch">Tìm kiếm</button>
</form>
<% if (listIngredient != null) { %>
<div class="label-bold">Kết quả tìm kiếm:</div>
    <% if (listIngredient.isEmpty()) { %>
    <div class="alert warn">Không tìm thấy nguyên liệu, bạn có muốn thêm mới không?
        <a class="btn sm" style="margin-left:8px;" href="<%= ctxPath %>/kho/AddIngredientView0.jsp?name=<%= java.net.URLEncoder.encode(Format0.trim(txtIngredientName), "UTF-8") %>">Thêm mới</a></div>
    <% } else { %>
    <div class="table-wrap"><table class="tbl">
        <thead><tr><th>TT</th><th>Mã NL</th><th>Tên nguyên liệu</th><th>Đơn vị tính</th><th>Chọn</th></tr></thead>
        <tbody>
        <% int k = 0; for (Ingredient0 ing : listIngredient) { k++; %>
        <tr><td><%= k %></td><td><%= ing.getCode() %></td><td><%= Format0.h(ing.getName()) %></td><td><%= Format0.h(ing.getUnit()) %></td>
            <td><a href="<%= ctxPath %>/kho/EnterQuantityView0.jsp?id=<%= ing.getId() %>">Chọn</a>
                <% if (inList.contains(ing.getId())) { %><span class="badge">đã có</span><% } %></td></tr>
        <% } %>
        </tbody>
    </table></div>
    <% } %>
<% } %>
<div class="label-bold">Danh sách nguyên liệu nhập:</div>
<div class="table-wrap"><table class="tbl">
    <thead><tr><th>TT</th><th>Nguyên liệu</th><th>ĐVT</th><th class="num">Số lượng</th><th class="num">Đơn giá</th><th class="num">Thành tiền</th><th>Sửa</th><th>Xóa</th></tr></thead>
    <tbody>
    <% for (int i = 0; i < listDetail.size(); i++) { ImportDetail0 d = listDetail.get(i); %>
    <tr><td><%= i + 1 %></td><td><%= Format0.h(d.getIngredient().getName()) %></td><td><%= Format0.h(d.getIngredient().getUnit()) %></td>
        <td class="num"><%= Format0.qty(d.getQuantity()) %></td><td class="num"><%= Format0.money(d.getUnitPrice()) %></td>
        <td class="num"><%= Format0.money(d.getAmount()) %></td>
        <td><a href="<%= ctxPath %>/kho/EnterQuantityView0.jsp?id=<%= d.getIngredient().getId() %>&edit=1">Sửa</a></td>
        <td><form method="post" style="margin:0;"><input type="hidden" name="action" value="remove"><input type="hidden" name="idx" value="<%= i %>">
            <button class="btn link" type="submit">Xóa</button></form></td></tr>
    <% } %>
    <% if (listDetail.isEmpty()) { %><tr><td colspan="8" class="empty">Chưa có nguyên liệu nào.</td></tr><% } %>
    </tbody>
</table></div>
<div class="total-line">Tổng tiền: <%= Format0.money(total) %></div>
<form method="post" class="actions">
    <a class="btn" href="<%= ctxPath %>/kho/AddIngredientView0.jsp">Thêm nguyên liệu mới</a>
    <button class="btn" type="submit" name="action" value="confirm">Xác nhận</button>
    <button class="btn" type="submit" name="action" value="cancel"
            onclick="return confirm('Hủy phiếu nhập đang lập? Phiếu sẽ không được lưu.');">Hủy phiếu</button>
</form>
<%@ include file="/common/footer.jspf" %>

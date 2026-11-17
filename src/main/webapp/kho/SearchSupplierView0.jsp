<%-- Man hinh 2 - Tim nha cung cap. Thiet ke: -txtSupplierName : TextBox, -btnSearch : submit, -listSupplier : Supplier0[],
     -tblSupplier : Table, -lnkSelectSupplier : link, -btnAddSupplier : submit, -staff : WarehouseStaff0.
     mode=import: chon nha cung cap de lap phieu nhap; mode=manage: quan ly thong tin nha cung cap (cot Sua thay cot Chon). --%>
<% String REQUIRED_ROLE = "WAREHOUSE"; String mode = "manage".equals(request.getParameter("mode")) ? "manage" : "import";
   String PAGE_TITLE = "import".equals(mode) ? "Tìm nhà cung cấp" : "Quản lý thông tin nhà cung cấp";
   String MENU = "import".equals(mode) ? "import" : "supplier"; String SIZE = "m"; %>
<%@ include file="/common/guard.jspf" %>
<%
    String txtSupplierName = request.getParameter("txtSupplierName");
    boolean searched = txtSupplierName != null;
    List<Supplier0> listSupplier = null;
    if (searched || "manage".equals(mode)) listSupplier = new SupplierDAO0().searchSupplier(searched ? txtSupplierName : "");
    int newId = Format0.parseInt(request.getParameter("new"), 0);
    Supplier0 current = (Supplier0) session.getAttribute("importSupplier");
%>
<%@ include file="/common/header.jspf" %>
<% if ("import".equals(mode) && current != null) { %>
<div class="alert warn">Đang lập dở phiếu nhập với <b><%= Format0.h(current.getName()) %></b>.
    <a href="<%= ctxPath %>/kho/ImportIngredientView0.jsp">Tiếp tục phiếu đang lập</a> hoặc chọn nhà cung cấp khác (phiếu đang lập sẽ được làm mới).</div>
<% } %>
<form method="get" class="inline-form">
    <input type="hidden" name="mode" value="<%= mode %>">
    <div class="form-row">
        <label for="txtSupplierName">Tên nhà cung cấp:</label>
        <input type="text" id="txtSupplierName" name="txtSupplierName" value="<%= Format0.h(txtSupplierName) %>" autofocus>
    </div>
    <button class="btn" type="submit" name="btnSearch">Tìm kiếm</button>
</form>
<% if (listSupplier != null) { %>
<div class="label-bold">Kết quả tìm kiếm:</div>
<% if (listSupplier.isEmpty()) { %>
<div class="alert warn">Không tìm thấy nhà cung cấp, bạn có muốn thêm mới không?
    <a class="btn sm" style="margin-left:10px;" href="<%= ctxPath %>/kho/AddSupplierView0.jsp?mode=<%= mode %>&name=<%= java.net.URLEncoder.encode(Format0.trim(txtSupplierName), "UTF-8") %>">Thêm mới</a></div>
<% } else { %>
<div class="table-wrap">
    <table class="tbl">
        <thead><tr><th>TT</th><th>Mã NCC</th><th>Tên nhà cung cấp</th><th>Địa chỉ</th><th>Điện thoại</th><th><%= "import".equals(mode) ? "Chọn" : "Sửa" %></th></tr></thead>
        <tbody>
        <% int i = 0; for (Supplier0 s : listSupplier) { i++; %>
        <tr class="<%= s.getId() == newId ? "highlight" : "" %>">
            <td><%= i %></td><td><%= s.getCode() %></td><td><%= Format0.h(s.getName()) %></td>
            <td><%= Format0.h(s.getAddress()) %></td><td><%= Format0.h(s.getPhone()) %></td>
            <td>
                <% if ("import".equals(mode)) { %><a href="<%= ctxPath %>/kho/ImportIngredientView0.jsp?supplierId=<%= s.getId() %>">Chọn</a>
                <% } else { %><a href="<%= ctxPath %>/kho/EditSupplierView0.jsp?id=<%= s.getId() %>">Sửa</a><% } %>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>
<% } %>
<% } %>
<div class="actions">
    <a class="btn" href="<%= ctxPath %>/kho/AddSupplierView0.jsp?mode=<%= mode %>">Thêm nhà cung cấp mới</a>
    <a class="btn" href="<%= ctxPath %>/kho/WarehouseHomeView0.jsp">Về trang chủ</a>
</div>
<%@ include file="/common/footer.jspf" %>

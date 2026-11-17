<%-- Man hinh 2 - Danh sach mon an. Thiet ke: -listDish : Dish0[], -tblDish : Table, -btnAddNew : submit, -lnkEdit : link, -lnkDelete : link --%>
<% String REQUIRED_ROLE = "MANAGER"; String PAGE_TITLE = "Quản lý thông tin món ăn"; String MENU = "dish"; String SIZE = "m"; %>
<%@ include file="/common/guard.jspf" %>
<%
    List<Dish0> listDish = new DishDAO0().getDishList();
    int newId = Format0.parseInt(request.getParameter("new"), 0);
%>
<%@ include file="/common/header.jspf" %>
<div class="table-wrap">
    <table class="tbl">
        <thead>
        <tr><th>TT</th><th>Mã món</th><th>Tên món ăn</th><th>Danh mục</th><th class="num">Giá bán</th><th>Trạng thái</th><th>Sửa</th><th>Xóa</th></tr>
        </thead>
        <tbody>
        <% int i = 0; for (Dish0 d : listDish) { i++; %>
        <tr class="<%= d.getId() == newId ? "highlight" : "" %>">
            <td><%= i %></td>
            <td><%= Format0.h(d.getCode()) %></td>
            <td><%= Format0.h(d.getName()) %></td>
            <td><%= Format0.h(d.getCategory().getName()) %></td>
            <td class="num"><%= Format0.money(d.getSellingPrice()) %></td>
            <td><%= Format0.h(d.getStatus()) %></td>
            <td><a href="<%= ctxPath %>/quanly/EditDishView0.jsp?id=<%= d.getId() %>">Sửa</a></td>
            <td>
                <form method="post" action="<%= ctxPath %>/quanly/doDeleteDish0.jsp" style="margin:0;"
                      onsubmit="return confirm('Xóa món <%= Format0.h(d.getName()).replace("'", "\\'") %>? Món đã có trong đơn gọi món hoặc combo sẽ được chuyển sang Ngừng bán.');">
                    <input type="hidden" name="id" value="<%= d.getId() %>">
                    <button class="btn link" type="submit">Xóa</button>
                </form>
            </td>
        </tr>
        <% } %>
        <% if (listDish.isEmpty()) { %><tr><td colspan="8" class="empty">Chưa có món ăn nào.</td></tr><% } %>
        </tbody>
    </table>
</div>
<div class="actions">
    <a class="btn" href="<%= ctxPath %>/quanly/AddDishView0.jsp" name="btnAddNew">Thêm mới</a>
    <a class="btn" href="<%= ctxPath %>/quanly/ManagerHomeView0.jsp">Về trang chủ</a>
</div>
<%@ include file="/common/footer.jspf" %>

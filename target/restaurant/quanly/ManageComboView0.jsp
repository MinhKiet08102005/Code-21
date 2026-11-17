<%-- Lap thuc don combo: danh sach combo. --%>
<% String REQUIRED_ROLE = "MANAGER"; String PAGE_TITLE = "Lập thực đơn combo"; String MENU = "combo"; String SIZE = "l"; %>
<%@ include file="/common/guard.jspf" %>
<%
    List<Combo0> combos = new ComboDAO0().getComboList();
    int newId = Format0.parseInt(request.getParameter("new"), 0);
%>
<%@ include file="/common/header.jspf" %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Lập thực đơn combo</div>
        <h1>Thực đơn combo</h1>
    </div>
    <a class="btn" href="<%= ctxPath %>/quanly/AddComboView0.jsp">+ Lập combo mới</a>
</div>
<div class="card">
    <div class="table-wrap">
        <table class="tbl">
            <thead><tr><th>Mã</th><th>Tên combo</th><th>Gồm các món</th><th class="num">Giá mua lẻ</th><th class="num">Giá combo</th><th class="num">Tiết kiệm</th><th>Trạng thái</th><th></th></tr></thead>
            <tbody>
            <% for (Combo0 c : combos) {
                BigDecimal orig = c.getOriginalPrice(); %>
            <tr class="<%= c.getId() == newId ? "highlight" : "" %>">
                <td><%= Format0.h(c.getCode()) %></td>
                <td><b><%= Format0.h(c.getName()) %></b><div class="small muted"><%= Format0.h(c.getDescription()) %></div></td>
                <td class="small">
                    <% for (ComboDetail0 d : c.getDetails()) { %><div><%= d.getQuantity() %> × <%= Format0.h(d.getDish().getName()) %></div><% } %>
                </td>
                <td class="num"><%= Format0.money(orig) %></td>
                <td class="num"><b><%= Format0.money(c.getPrice()) %></b></td>
                <td class="num"><%= Format0.money(orig.subtract(c.getPrice())) %></td>
                <td><span class="badge <%= DishDAO0.AVAILABLE.equals(c.getStatus()) ? "green" : "red" %>"><%= Format0.h(c.getStatus()) %></span></td>
                <td>
                    <form method="post" action="<%= ctxPath %>/quanly/doSaveCombo0.jsp" style="margin:0;">
                        <input type="hidden" name="action" value="toggle">
                        <input type="hidden" name="id" value="<%= c.getId() %>">
                        <button class="btn sm secondary" type="submit"><%= DishDAO0.AVAILABLE.equals(c.getStatus()) ? "Ngừng bán" : "Mở bán lại" %></button>
                    </form>
                </td>
            </tr>
            <% } %>
            <% if (combos.isEmpty()) { %><tr><td colspan="8" class="empty">Chưa có combo nào.</td></tr><% } %>
            </tbody>
        </table>
    </div>
</div>
<%@ include file="/common/footer.jspf" %>

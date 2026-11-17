<%-- Form lap combo moi: chon mon va so luong, dat gia uu dai. --%>
<% String REQUIRED_ROLE = "MANAGER"; String PAGE_TITLE = "Lập combo mới"; String MENU = "combo"; String SIZE = "l"; %>
<%@ include file="/common/guard.jspf" %>
<%
    List<Dish0> dishes = new DishDAO0().searchDish("");
    @SuppressWarnings("unchecked")
    Map<String, String> errors = (Map<String, String>) request.getAttribute("errors");
    if (errors == null) errors = new HashMap<>();
%>
<%@ include file="/common/header.jspf" %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Lập thực đơn combo / Lập combo mới</div>
        <h1>Lập combo mới</h1>
    </div>
</div>
<form method="post" action="<%= ctxPath %>/quanly/doSaveCombo0.jsp" novalidate>
    <input type="hidden" name="action" value="add">
    <div class="grid grid-2" style="align-items: start;">
        <div class="card">
            <h3>Thông tin combo</h3>
            <% if (errors.containsKey("general")) { %><div class="alert err"><%= errors.get("general") %></div><% } %>
            <div class="form-row <%= errors.containsKey("name") ? "field-error" : "" %>">
                <label>Tên combo <span class="req">*</span></label>
                <input type="text" name="txtName" value="<%= Format0.h(request.getParameter("txtName")) %>" maxlength="100">
                <% if (errors.containsKey("name")) { %><div class="err-text"><%= errors.get("name") %></div><% } %>
            </div>
            <div class="form-row <%= errors.containsKey("price") ? "field-error" : "" %>">
                <label>Giá combo (đồng) <span class="req">*</span></label>
                <input type="text" name="txtPrice" id="txtPrice" value="<%= Format0.h(request.getParameter("txtPrice")) %>" oninput="recalc()">
                <% if (errors.containsKey("price")) { %><div class="err-text"><%= errors.get("price") %></div><% } %>
            </div>
            <div class="form-row">
                <label>Mô tả</label>
                <textarea name="txtDescription" maxlength="500"><%= Format0.h(request.getParameter("txtDescription")) %></textarea>
            </div>
            <div class="alert info" id="summary">Chọn món ở bảng bên cạnh.</div>
            <div class="actions">
                <button class="btn" type="submit">Lưu combo</button>
                <a class="btn secondary" href="<%= ctxPath %>/quanly/ManageComboView0.jsp">Hủy</a>
            </div>
        </div>
        <div class="card">
            <h3>Chọn món trong combo <span class="req">*</span></h3>
            <% if (errors.containsKey("items")) { %><div class="alert err"><%= errors.get("items") %></div><% } %>
            <div class="table-wrap">
                <table class="tbl">
                    <thead><tr><th>Món ăn</th><th class="num">Giá bán</th><th>Số lượng</th></tr></thead>
                    <tbody>
                    <% for (Dish0 d : dishes) { String v = request.getParameter("qty_" + d.getId()); %>
                    <tr>
                        <td><%= Format0.h(d.getName()) %> <span class="small muted">· <%= Format0.h(d.getCategory().getName()) %></span></td>
                        <td class="num"><%= Format0.money(d.getSellingPrice()) %></td>
                        <td><input class="qty-input" type="number" min="0" max="50" name="qty_<%= d.getId() %>" value="<%= v == null ? "0" : Format0.h(v) %>"
                                   data-price="<%= d.getSellingPrice().toPlainString() %>" oninput="recalc()"></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</form>
<script>
    function fmt(n) { return Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.') + ' VNĐ'; }
    function recalc() {
        var total = 0, kinds = 0;
        document.querySelectorAll('input[data-price]').forEach(function (i) {
            var q = parseInt(i.value || '0', 10);
            if (q > 0) { total += q * parseFloat(i.dataset.price); kinds++; }
        });
        var p = parseFloat((document.getElementById('txtPrice').value || '').replace(/\./g, '').replace(',', '.'));
        var s = kinds + ' món, giá mua lẻ ' + fmt(total);
        if (p > 0 && total > 0) s += ' · giá combo ' + fmt(p) + (p < total ? ' · tiết kiệm ' + fmt(total - p) : ' · chưa rẻ hơn mua lẻ');
        document.getElementById('summary').textContent = s;
    }
    recalc();
</script>
<%@ include file="/common/footer.jspf" %>

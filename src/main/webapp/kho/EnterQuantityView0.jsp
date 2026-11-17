<%-- Nhap so luong va don gia. Thiet ke: -ingredient : Ingredient0, -txtQuantity : TextBox, -txtUnitPrice : TextBox,
     -btnAddToList : submit, -btnCancel : submit --%>
<% String REQUIRED_ROLE = "WAREHOUSE"; String PAGE_TITLE = "Nhập số lượng nguyên liệu"; String MENU = "import"; String SIZE = "s"; %>
<%@ include file="/common/guard.jspf" %>
<%
    Supplier0 supplier = (Supplier0) session.getAttribute("importSupplier");
    @SuppressWarnings("unchecked")
    List<ImportDetail0> listDetail = (List<ImportDetail0>) session.getAttribute("importDetails");
    Ingredient0 ingredient = new IngredientDAO0().getIngredientById(Format0.parseInt(request.getParameter("id"), 0));
    if (supplier == null || listDetail == null || ingredient == null) {
        response.sendRedirect(request.getContextPath() + "/kho/ImportIngredientView0.jsp");
        return;
    }
    boolean edit = "1".equals(request.getParameter("edit"));
    ImportDetail0 existing = null;
    for (ImportDetail0 d : listDetail) if (d.getIngredient().getId() == ingredient.getId()) existing = d;
    if (edit && existing == null) edit = false;

    Map<String, String> errors = new LinkedHashMap<>();
    String qText = request.getParameter("txtQuantity");
    String pText = request.getParameter("txtUnitPrice");
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        BigDecimal q = Format0.parseNumber(qText);
        BigDecimal p = Format0.parseNumber(pText);
        // Ngoai le 11.1: so luong, don gia phai la so lon hon 0
        if (q == null || q.signum() <= 0) errors.put("q", "Số lượng và đơn giá phải là số lớn hơn 0");
        if (p == null || p.signum() <= 0) errors.put("p", "Số lượng và đơn giá phải là số lớn hơn 0");
        if (errors.isEmpty()) {
            if (existing != null && edit) {
                existing.setQuantity(q);
                existing.setUnitPrice(p);
                existing.calculateAmount();
                session.setAttribute("flashOk", "Đã cập nhật " + ingredient.getName() + ".");
            } else if (existing != null) {
                // Ngoai le 12.1: nguyen lieu da co trong phieu -> cong don so luong (nhan vien da dong y o man hinh nay)
                existing.setQuantity(existing.getQuantity().add(q));
                existing.setUnitPrice(p);
                existing.calculateAmount();
                session.setAttribute("flashOk", "Đã cộng dồn số lượng " + ingredient.getName() + " thành " + Format0.qty(existing.getQuantity()) + " " + ingredient.getUnit() + ".");
            } else {
                ImportDetail0 d = new ImportDetail0();
                d.setIngredient(ingredient);
                d.setQuantity(q);
                d.setUnitPrice(p);
                d.calculateAmount();
                listDetail.add(d);
                session.setAttribute("flashOk", "Đã thêm " + ingredient.getName() + " vào phiếu.");
            }
            response.sendRedirect(request.getContextPath() + "/kho/ImportIngredientView0.jsp");
            return;
        }
    } else if (edit) {
        qText = existing.getQuantity().stripTrailingZeros().toPlainString();
        pText = existing.getUnitPrice().stripTrailingZeros().toPlainString();
    }
%>
<%@ include file="/common/header.jspf" %>
<p class="line">Nguyên liệu: <%= Format0.h(ingredient.getName()) %> (<%= ingredient.getCode() %>)</p>
<p class="line">Đơn vị tính: <%= Format0.h(ingredient.getUnit()) %></p>
<% if (existing != null && !edit) { %>
<div class="alert warn">Nguyên liệu đã có trong phiếu (<%= Format0.qty(existing.getQuantity()) %> <%= Format0.h(ingredient.getUnit()) %>, đơn giá <%= Format0.money(existing.getUnitPrice()) %>).
    Bấm "Cộng dồn vào phiếu" để cộng thêm số lượng, đơn giá cập nhật theo giá vừa nhập; hoặc bấm Hủy.</div>
<% } %>
<form method="post" novalidate>
    <div class="form-row <%= errors.containsKey("q") ? "field-error" : "" %>">
        <label for="txtQuantity">Số lượng:</label>
        <input type="text" id="txtQuantity" name="txtQuantity" value="<%= Format0.h(qText) %>" autofocus>
        <span class="req">(*)</span>
        <% if (errors.containsKey("q")) { %><div class="err-text"><%= errors.get("q") %></div><% } %>
    </div>
    <div class="form-row <%= errors.containsKey("p") ? "field-error" : "" %>">
        <label for="txtUnitPrice">Đơn giá (VNĐ):</label>
        <input type="text" id="txtUnitPrice" name="txtUnitPrice" value="<%= Format0.h(pText) %>">
        <span class="req">(*)</span>
        <% if (errors.containsKey("p")) { %><div class="err-text"><%= errors.get("p") %></div><% } %>
    </div>
    <div class="actions">
        <button class="btn" type="submit" name="btnAddToList"><%= edit ? "Cập nhật" : (existing != null ? "Cộng dồn vào phiếu" : "Thêm vào danh sách") %></button>
        <a class="btn" href="<%= ctxPath %>/kho/ImportIngredientView0.jsp">Hủy</a>
    </div>
</form>
<%@ include file="/common/footer.jspf" %>

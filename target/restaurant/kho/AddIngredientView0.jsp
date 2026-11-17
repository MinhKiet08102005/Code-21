<%-- Them nguyen lieu moi. Thiet ke: -txtIngredientName : TextBox, -txtUnit : TextBox, -txtDescription : TextArea, -btnSave, -btnCancel --%>
<% String REQUIRED_ROLE = "WAREHOUSE"; String PAGE_TITLE = "Thêm nguyên liệu mới"; String MENU = "import"; String SIZE = "m"; %>
<%@ include file="/common/guard.jspf" %>
<%
    Map<String, String> errors = new LinkedHashMap<>();
    String generalError = null;
    String name = request.getParameter("txtIngredientName");
    if (name == null) name = request.getParameter("name");
    String unit = request.getParameter("txtUnit");
    String description = request.getParameter("txtDescription");
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        IngredientDAO0 dao = new IngredientDAO0();
        if (Format0.blank(name)) errors.put("name", "Vui lòng nhập tên nguyên liệu");
        else if (dao.checkDuplicateName(name)) errors.put("name", "Nguyên liệu này đã có trong hệ thống, hãy tìm và chọn ở màn hình lập phiếu");
        if (Format0.blank(unit)) errors.put("unit", "Vui lòng nhập đơn vị tính");
        if (errors.isEmpty()) {
            Ingredient0 ing = new Ingredient0();
            ing.setName(name.trim());
            ing.setUnit(unit.trim());
            ing.setDescription(Format0.nullIfBlank(description));
            if (dao.addIngredient(ing)) {
                session.setAttribute("flashOk", "Đã thêm nguyên liệu " + ing.getCode() + " – " + ing.getName() + ". Bấm Chọn để nhập số lượng.");
                response.sendRedirect(request.getContextPath() + "/kho/ImportIngredientView0.jsp?txtIngredientName="
                        + java.net.URLEncoder.encode(ing.getName(), "UTF-8"));
                return;
            }
            generalError = "Không lưu được nguyên liệu, vui lòng thử lại.";
        }
    }
    boolean inImport = session.getAttribute("importSupplier") != null;
%>
<%@ include file="/common/header.jspf" %>
<% if (generalError != null) { %><div class="alert err"><%= generalError %></div><% } %>
<form method="post" novalidate>
    <div class="form-row <%= errors.containsKey("name") ? "field-error" : "" %>">
        <label for="txtIngredientName">Tên nguyên liệu:</label>
        <input type="text" id="txtIngredientName" name="txtIngredientName" value="<%= Format0.h(name) %>" maxlength="100">
        <span class="req">(*)</span>
        <% if (errors.containsKey("name")) { %><div class="err-text"><%= errors.get("name") %></div><% } %>
    </div>
    <div class="form-row <%= errors.containsKey("unit") ? "field-error" : "" %>">
        <label for="txtUnit">Đơn vị tính:</label>
        <input type="text" id="txtUnit" name="txtUnit" value="<%= Format0.h(unit) %>" list="units" maxlength="20">
        <datalist id="units"><option>kg</option><option>lít</option><option>hộp</option><option>bó</option><option>quả</option><option>gói</option><option>chai</option></datalist>
        <span class="req">(*)</span>
        <% if (errors.containsKey("unit")) { %><div class="err-text"><%= errors.get("unit") %></div><% } %>
    </div>
    <div class="form-row top">
        <label for="txtDescription">Mô tả:</label>
        <textarea id="txtDescription" name="txtDescription" maxlength="500"><%= Format0.h(description) %></textarea>
    </div>
    <div class="actions">
        <button class="btn" type="submit" name="btnSave">Lưu</button>
        <a class="btn" href="<%= ctxPath %><%= inImport ? "/kho/ImportIngredientView0.jsp" : "/kho/WarehouseHomeView0.jsp" %>">Hủy</a>
    </div>
    <div class="note">(*) Trường bắt buộc nhập</div>
</form>
<%@ include file="/common/footer.jspf" %>

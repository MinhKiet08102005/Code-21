<%-- Man hinh 3 - Form them mon an moi. Thiet ke: -txtDishName : TextBox, -cboCategory : Select, -listCategory : DishCategory0[],
     -txtSellingPrice : TextBox, -txtDescription : TextArea, -fileImage : FileUpload, -btnSave : submit, -btnCancel : submit --%>
<% String REQUIRED_ROLE = "MANAGER"; String PAGE_TITLE = "Thêm món ăn mới"; String MENU = "dish"; String SIZE = "m"; %>
<%@ include file="/common/guard.jspf" %>
<%
    List<DishCategory0> listCategory = new DishCategoryDAO0().getCategories();
    @SuppressWarnings("unchecked")
    Map<String, String> errors = (Map<String, String>) request.getAttribute("errors");
    if (errors == null) errors = new HashMap<>();
    String generalError = (String) request.getAttribute("generalError");
    String vName = Format0.h(request.getParameter("txtDishName"));
    int vCat = Format0.parseInt(request.getParameter("cboCategory"), 0);
    String vPrice = Format0.h(request.getParameter("txtSellingPrice"));
    String vDesc = Format0.h(request.getParameter("txtDescription"));
%>
<%@ include file="/common/header.jspf" %>
<% if (generalError != null) { %><div class="alert err"><%= Format0.h(generalError) %></div><% } %>
<form id="dishForm" method="post" action="<%= ctxPath %>/quanly/doSaveDish0.jsp" enctype="multipart/form-data" novalidate>
    <div class="form-row <%= errors.containsKey("name") ? "field-error" : "" %>">
        <label for="txtDishName">Tên món ăn:</label>
        <input type="text" id="txtDishName" name="txtDishName" value="<%= vName %>" maxlength="100">
        <span class="req">(*)</span>
        <% if (errors.containsKey("name")) { %><div class="err-text"><%= errors.get("name") %></div><% } %>
    </div>
    <div class="form-row <%= errors.containsKey("category") ? "field-error" : "" %>">
        <label for="cboCategory">Danh mục:</label>
        <select id="cboCategory" name="cboCategory">
            <option value="">-- Chọn danh mục --</option>
            <% for (DishCategory0 c : listCategory) { %>
            <option value="<%= c.getId() %>" <%= c.getId() == vCat ? "selected" : "" %>><%= Format0.h(c.getName()) %></option>
            <% } %>
        </select>
        <span class="req">(*)</span>
        <% if (errors.containsKey("category")) { %><div class="err-text"><%= errors.get("category") %></div><% } %>
    </div>
    <div class="form-row <%= errors.containsKey("price") ? "field-error" : "" %>">
        <label for="txtSellingPrice">Giá bán (VNĐ):</label>
        <input type="text" id="txtSellingPrice" name="txtSellingPrice" value="<%= vPrice %>">
        <span class="req">(*)</span>
        <% if (errors.containsKey("price")) { %><div class="err-text"><%= errors.get("price") %></div><% } %>
    </div>
    <div class="form-row top">
        <label for="txtDescription">Mô tả:</label>
        <textarea id="txtDescription" name="txtDescription" maxlength="500"><%= vDesc %></textarea>
    </div>
    <div class="form-row <%= errors.containsKey("image") ? "field-error" : "" %>">
        <label for="fileImage">Hình ảnh:</label>
        <input type="file" id="fileImage" name="fileImage" accept=".jpg,.jpeg,.png">
        <% if (errors.containsKey("image")) { %><div class="err-text"><%= errors.get("image") %></div><% } %>
    </div>
    <div class="actions">
        <button class="btn" type="submit" name="btnSave">Lưu</button>
        <a class="btn" href="<%= ctxPath %>/quanly/ManageDishView0.jsp" onclick="return confirmCancel();">Hủy</a>
    </div>
    <div class="note">(*) Trường bắt buộc nhập</div>
</form>
<script>
    function confirmCancel() {
        var f = document.getElementById('dishForm');
        var dirty = f.txtDishName.value || f.txtSellingPrice.value || f.txtDescription.value || f.cboCategory.value || f.fileImage.value;
        return !dirty || confirm('Bạn đang nhập dở. Hủy thêm món ăn? Món ăn mới sẽ không được tạo.');
    }
</script>
<%@ include file="/common/footer.jspf" %>

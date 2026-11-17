<%-- Sua thong tin mon an (use case Sua mon an, mo rong tu Quan li thong tin mon an). --%>
<% String REQUIRED_ROLE = "MANAGER"; String PAGE_TITLE = "Sửa món ăn"; String MENU = "dish"; String SIZE = "s"; %>
<%@ include file="/common/guard.jspf" %>
<%
    int id = Format0.parseInt(request.getParameter("id"), 0);
    Dish0 dish = new DishDAO0().getDishById(id);
    if (dish == null) {
        session.setAttribute("flashErr", "Không tìm thấy món ăn.");
        response.sendRedirect(request.getContextPath() + "/quanly/ManageDishView0.jsp");
        return;
    }
    List<DishCategory0> listCategory = new DishCategoryDAO0().getCategories();
    @SuppressWarnings("unchecked")
    Map<String, String> errors = (Map<String, String>) request.getAttribute("errors");
    boolean back = errors != null;
    if (errors == null) errors = new HashMap<>();
    String generalError = (String) request.getAttribute("generalError");
    String vName = back ? request.getParameter("txtDishName") : dish.getName();
    int vCat = back ? Format0.parseInt(request.getParameter("cboCategory"), 0) : dish.getCategory().getId();
    String vPrice = back ? request.getParameter("txtSellingPrice") : dish.getSellingPrice().stripTrailingZeros().toPlainString();
    String vDesc = back ? request.getParameter("txtDescription") : dish.getDescription();
    String vStatus = back ? request.getParameter("cboStatus") : dish.getStatus();
%>
<% request.setAttribute("screenTitle", "Sửa món ăn " + dish.getCode()); %>
<%@ include file="/common/header.jspf" %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Quản lí thông tin món ăn / Sửa món ăn</div>
        <h1>Sửa món ăn <%= Format0.h(dish.getCode()) %></h1>
    </div>
</div>
<div class="card narrow">
    <% if (generalError != null) { %><div class="alert err"><%= Format0.h(generalError) %></div><% } %>
    <form method="post" action="<%= ctxPath %>/quanly/doUpdateDish0.jsp" enctype="multipart/form-data" novalidate>
        <input type="hidden" name="id" value="<%= dish.getId() %>">
        <div class="form-row <%= errors.containsKey("name") ? "field-error" : "" %>">
            <label>Tên món ăn <span class="req">*</span></label>
            <input type="text" name="txtDishName" value="<%= Format0.h(vName) %>" maxlength="100">
            <% if (errors.containsKey("name")) { %><div class="err-text"><%= errors.get("name") %></div><% } %>
        </div>
        <div class="grid grid-2">
            <div class="form-row <%= errors.containsKey("category") ? "field-error" : "" %>">
                <label>Danh mục <span class="req">*</span></label>
                <select name="cboCategory">
                    <% for (DishCategory0 c : listCategory) { %>
                    <option value="<%= c.getId() %>" <%= c.getId() == vCat ? "selected" : "" %>><%= Format0.h(c.getName()) %></option>
                    <% } %>
                </select>
                <% if (errors.containsKey("category")) { %><div class="err-text"><%= errors.get("category") %></div><% } %>
            </div>
            <div class="form-row">
                <label>Trạng thái</label>
                <select name="cboStatus">
                    <option <%= DishDAO0.AVAILABLE.equals(vStatus) ? "selected" : "" %>><%= DishDAO0.AVAILABLE %></option>
                    <option <%= DishDAO0.STOPPED.equals(vStatus) ? "selected" : "" %>><%= DishDAO0.STOPPED %></option>
                </select>
            </div>
        </div>
        <div class="form-row <%= errors.containsKey("price") ? "field-error" : "" %>">
            <label>Giá bán (đồng) <span class="req">*</span></label>
            <input type="text" name="txtSellingPrice" value="<%= Format0.h(vPrice) %>">
            <% if (errors.containsKey("price")) { %><div class="err-text"><%= errors.get("price") %></div><% } %>
        </div>
        <div class="form-row">
            <label>Mô tả</label>
            <textarea name="txtDescription" maxlength="500"><%= Format0.h(vDesc) %></textarea>
        </div>
        <div class="form-row <%= errors.containsKey("image") ? "field-error" : "" %>">
            <label>Hình ảnh</label>
            <% if (dish.getImagePath() != null) { %>
            <div style="margin-bottom:8px;"><img src="<%= ctxPath %>/<%= Format0.h(dish.getImagePath()) %>" alt="" style="max-height:110px; border-radius:8px;"></div>
            <% } %>
            <input type="file" name="fileImage" accept=".jpg,.jpeg,.png">
            <div class="hint">Để trống nếu giữ ảnh hiện tại. Chỉ nhận JPG hoặc PNG dưới 2MB.</div>
            <% if (errors.containsKey("image")) { %><div class="err-text"><%= errors.get("image") %></div><% } %>
        </div>
        <div class="actions">
            <button class="btn" type="submit">Lưu thay đổi</button>
            <a class="btn secondary" href="<%= ctxPath %>/quanly/ManageDishView0.jsp">Hủy</a>
        </div>
    </form>
</div>
<%@ include file="/common/footer.jspf" %>

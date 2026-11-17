<%-- Sua / xoa nha cung cap (Quan li thong tin nha cung cap). --%>
<% String REQUIRED_ROLE = "WAREHOUSE"; String PAGE_TITLE = "Sửa nhà cung cấp"; String MENU = "supplier"; String SIZE = "s"; %>
<%@ include file="/common/guard.jspf" %>
<%
    SupplierDAO0 dao = new SupplierDAO0();
    Supplier0 s = dao.getSupplierById(Format0.parseInt(request.getParameter("id"), 0));
    if (s == null) {
        session.setAttribute("flashErr", "Không tìm thấy nhà cung cấp.");
        response.sendRedirect(request.getContextPath() + "/kho/SearchSupplierView0.jsp?mode=manage");
        return;
    }
    Map<String, String> errors = new LinkedHashMap<>();
    String generalError = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if ("delete".equals(request.getParameter("action"))) {
            if (dao.deleteSupplier(s.getId())) {
                session.setAttribute("flashOk", "Đã xóa nhà cung cấp " + s.getName() + ".");
                response.sendRedirect(request.getContextPath() + "/kho/SearchSupplierView0.jsp?mode=manage");
                return;
            }
            generalError = "Không xóa được: nhà cung cấp đã có phiếu nhập. Có thể sửa thông tin thay vì xóa.";
        } else {
            s.setName(Format0.trim(request.getParameter("txtSupplierName")));
            s.setAddress(Format0.trim(request.getParameter("txtAddress")));
            s.setPhone(Format0.trim(request.getParameter("txtPhone")));
            s.setEmail(Format0.nullIfBlank(request.getParameter("txtEmail")));
            s.setDescription(Format0.nullIfBlank(request.getParameter("txtDescription")));
            if (s.getName().isEmpty()) errors.put("name", "Vui lòng nhập tên nhà cung cấp");
            if (s.getAddress().isEmpty()) errors.put("address", "Vui lòng nhập địa chỉ");
            if (!s.getPhone().matches("0\\d{9,10}")) errors.put("phone", "Số điện thoại phải gồm 10–11 chữ số, bắt đầu bằng 0");
            if (!Format0.validEmail(s.getEmail())) errors.put("email", "Email không đúng định dạng");
            if (errors.isEmpty()) {
                if (dao.updateSupplier(s)) {
                    session.setAttribute("flashOk", "Đã cập nhật nhà cung cấp " + s.getCode() + ".");
                    response.sendRedirect(request.getContextPath() + "/kho/SearchSupplierView0.jsp?mode=manage&new=" + s.getId());
                    return;
                }
                generalError = "Không lưu được, vui lòng thử lại.";
            }
        }
    }
%>
<% request.setAttribute("screenTitle", "Sửa nhà cung cấp " + s.getCode()); %>
<%@ include file="/common/header.jspf" %>
<div class="page-head">
    <div>
        <div class="breadcrumb">Trang chủ / Quản lí thông tin nhà cung cấp / Sửa</div>
        <h1>Sửa nhà cung cấp <%= s.getCode() %></h1>
    </div>
</div>
<div class="card narrow">
    <% if (generalError != null) { %><div class="alert err"><%= generalError %></div><% } %>
    <form method="post" novalidate>
        <div class="form-row <%= errors.containsKey("name") ? "field-error" : "" %>">
            <label>Tên nhà cung cấp <span class="req">*</span></label>
            <input type="text" name="txtSupplierName" value="<%= Format0.h(s.getName()) %>">
            <% if (errors.containsKey("name")) { %><div class="err-text"><%= errors.get("name") %></div><% } %>
        </div>
        <div class="form-row <%= errors.containsKey("address") ? "field-error" : "" %>">
            <label>Địa chỉ <span class="req">*</span></label>
            <input type="text" name="txtAddress" value="<%= Format0.h(s.getAddress()) %>">
            <% if (errors.containsKey("address")) { %><div class="err-text"><%= errors.get("address") %></div><% } %>
        </div>
        <div class="grid grid-2">
            <div class="form-row <%= errors.containsKey("phone") ? "field-error" : "" %>">
                <label>Điện thoại <span class="req">*</span></label>
                <input type="tel" name="txtPhone" value="<%= Format0.h(s.getPhone()) %>">
                <% if (errors.containsKey("phone")) { %><div class="err-text"><%= errors.get("phone") %></div><% } %>
            </div>
            <div class="form-row <%= errors.containsKey("email") ? "field-error" : "" %>">
                <label>Email</label>
                <input type="email" name="txtEmail" value="<%= Format0.h(s.getEmail()) %>">
                <% if (errors.containsKey("email")) { %><div class="err-text"><%= errors.get("email") %></div><% } %>
            </div>
        </div>
        <div class="form-row">
            <label>Mô tả</label>
            <textarea name="txtDescription"><%= Format0.h(s.getDescription()) %></textarea>
        </div>
        <div class="actions">
            <button class="btn" type="submit">Lưu thay đổi</button>
            <a class="btn secondary" href="<%= ctxPath %>/kho/SearchSupplierView0.jsp?mode=manage">Hủy</a>
            <span class="spacer" style="flex:1"></span>
            <button class="btn danger" type="submit" name="action" value="delete" formnovalidate
                    onclick="return confirm('Xóa nhà cung cấp này?');">Xóa nhà cung cấp</button>
        </div>
    </form>
</div>
<%@ include file="/common/footer.jspf" %>

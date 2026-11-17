<%-- Man hinh 3 - Them nha cung cap moi (nhanh extend). Thiet ke: -txtSupplierName, -txtAddress, -txtPhone, -txtEmail : TextBox, -btnSave, -btnCancel : submit --%>
<% String REQUIRED_ROLE = "WAREHOUSE"; String mode = "manage".equals(request.getParameter("mode")) ? "manage" : "import";
   String PAGE_TITLE = "Thêm nhà cung cấp mới"; String MENU = "import".equals(mode) ? "import" : "supplier"; String SIZE = "m"; %>
<%@ include file="/common/guard.jspf" %>
<%
    Map<String, String> errors = new LinkedHashMap<>();
    String generalError = null;
    String name = request.getParameter("txtSupplierName");
    if (name == null) name = request.getParameter("name");
    String address = request.getParameter("txtAddress");
    String phone = request.getParameter("txtPhone");
    String email = request.getParameter("txtEmail");
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (Format0.blank(name)) errors.put("name", "Vui lòng nhập tên nhà cung cấp");
        if (Format0.blank(address)) errors.put("address", "Vui lòng nhập địa chỉ");
        if (Format0.blank(phone)) errors.put("phone", "Vui lòng nhập số điện thoại");
        else if (!phone.trim().matches("0\\d{9,10}")) errors.put("phone", "Số điện thoại phải gồm 10–11 chữ số, bắt đầu bằng 0");
        if (!Format0.validEmail(email)) errors.put("email", "Email không đúng định dạng");
        if (errors.isEmpty()) {
            Supplier0 s = new Supplier0();
            s.setName(name.trim());
            s.setAddress(address.trim());
            s.setPhone(phone.trim());
            s.setEmail(Format0.nullIfBlank(email));
            if (new SupplierDAO0().addSupplier(s)) {
                session.setAttribute("flashOk", "Đã thêm nhà cung cấp " + s.getCode() + " – " + s.getName() + ".");
                response.sendRedirect(request.getContextPath() + "/kho/SearchSupplierView0.jsp?mode=" + mode + "&new=" + s.getId()
                        + "&txtSupplierName=" + java.net.URLEncoder.encode(s.getName(), "UTF-8"));
                return;
            }
            generalError = "Không lưu được nhà cung cấp, vui lòng thử lại.";
        }
    }
%>
<%@ include file="/common/header.jspf" %>
<% if (generalError != null) { %><div class="alert err"><%= generalError %></div><% } %>
<form method="post" novalidate>
    <input type="hidden" name="mode" value="<%= mode %>">
    <div class="form-row <%= errors.containsKey("name") ? "field-error" : "" %>">
        <label for="txtSupplierName">Tên nhà cung cấp:</label>
        <input type="text" id="txtSupplierName" name="txtSupplierName" value="<%= Format0.h(name) %>" maxlength="100">
        <span class="req">(*)</span>
        <% if (errors.containsKey("name")) { %><div class="err-text"><%= errors.get("name") %></div><% } %>
    </div>
    <div class="form-row <%= errors.containsKey("address") ? "field-error" : "" %>">
        <label for="txtAddress">Địa chỉ:</label>
        <input type="text" id="txtAddress" name="txtAddress" value="<%= Format0.h(address) %>" maxlength="255">
        <span class="req">(*)</span>
        <% if (errors.containsKey("address")) { %><div class="err-text"><%= errors.get("address") %></div><% } %>
    </div>
    <div class="form-row <%= errors.containsKey("phone") ? "field-error" : "" %>">
        <label for="txtPhone">Điện thoại:</label>
        <input type="tel" id="txtPhone" name="txtPhone" value="<%= Format0.h(phone) %>" maxlength="11">
        <span class="req">(*)</span>
        <% if (errors.containsKey("phone")) { %><div class="err-text"><%= errors.get("phone") %></div><% } %>
    </div>
    <div class="form-row <%= errors.containsKey("email") ? "field-error" : "" %>">
        <label for="txtEmail">Email:</label>
        <input type="email" id="txtEmail" name="txtEmail" value="<%= Format0.h(email) %>" maxlength="100">
        <% if (errors.containsKey("email")) { %><div class="err-text"><%= errors.get("email") %></div><% } %>
    </div>
    <div class="actions">
        <button class="btn" type="submit" name="btnSave">Lưu</button>
        <a class="btn" href="<%= ctxPath %>/kho/SearchSupplierView0.jsp?mode=<%= mode %>">Hủy</a>
    </div>
    <div class="note">(*) Trường bắt buộc nhập</div>
</form>
<%@ include file="/common/footer.jspf" %>

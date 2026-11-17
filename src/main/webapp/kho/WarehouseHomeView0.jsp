<%-- Man hinh 1 - Trang chu nhan vien kho. Thiet ke: -importIngredient : link, -staff : WarehouseStaff0 --%>
<% String REQUIRED_ROLE = "WAREHOUSE"; String PAGE_TITLE = "Trang chủ nhân viên kho"; String MENU = "home"; String SIZE = "s"; %>
<%@ include file="/common/guard.jspf" %>
<% boolean pending = session.getAttribute("importSupplier") != null; %>
<%@ include file="/common/header.jspf" %>
<p class="line">Nhân viên: <%= Format0.h(currentStaff.getFullName()) %></p>
<p class="line">Chức vụ: Nhân viên kho</p>
<br>
<a class="link-big" href="<%= ctxPath %>/kho/SearchSupplierView0.jsp?mode=import">Nhập nguyên liệu</a>
<a class="link-big" href="<%= ctxPath %>/kho/SearchSupplierView0.jsp?mode=manage">Quản lý thông tin nhà cung cấp</a>
<a class="link-big" href="<%= ctxPath %>/kho/ImportInvoiceListView0.jsp">Danh sách phiếu nhập</a>
<% if (pending) { %>
<p class="note">Bạn đang lập dở một phiếu nhập. <a href="<%= ctxPath %>/kho/ImportIngredientView0.jsp">Tiếp tục lập phiếu</a></p>
<% } %>
<%@ include file="/common/footer.jspf" %>

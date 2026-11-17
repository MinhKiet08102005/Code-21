<%-- Man hinh 1 - Trang chu nhan vien quan ly. Thiet ke: -manageDish : link, -staff : ManagementStaff0 --%>
<% String REQUIRED_ROLE = "MANAGER"; String PAGE_TITLE = "Trang chủ nhân viên quản lý"; String MENU = "home"; String SIZE = "s"; %>
<%@ include file="/common/guard.jspf" %>
<%@ include file="/common/header.jspf" %>
<p class="line">Nhân viên: <%= Format0.h(currentStaff.getFullName()) %></p>
<p class="line">Chức vụ: Nhân viên quản lý</p>
<br>
<a class="link-big" href="<%= ctxPath %>/quanly/ManageDishView0.jsp">Quản lý thông tin món ăn</a>
<a class="link-big" href="<%= ctxPath %>/quanly/ManageComboView0.jsp">Lập thực đơn combo</a>
<a class="link-big" href="<%= ctxPath %>/quanly/StatisticView0.jsp">Xem thống kê</a>
<%@ include file="/common/footer.jspf" %>

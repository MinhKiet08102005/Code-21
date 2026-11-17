<%
    Staff0 s = (Staff0) session.getAttribute("staff");
    String home = null;
    if (s != null) {
        if ("MANAGER".equals(s.getRole())) home = "/quanly/ManagerHomeView0.jsp";
        else if ("WAREHOUSE".equals(s.getRole())) home = "/kho/WarehouseHomeView0.jsp";
        else home = "/banhang/SaleHomeView0.jsp";
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hệ thống quản lý nhà hàng</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>
<body class="solo">
<div class="screen s">
    <div class="screen-title">Hệ thống quản lý nhà hàng</div>
    <div class="screen-body">
        <a class="link-big" href="<%= request.getContextPath() %>/khachhang/SearchDishView0.jsp">Dành cho khách hàng</a>
        <p class="line muted small" style="margin-top:-6px;">Tìm kiếm món ăn, đặt bàn trực tuyến, đặt món trực tuyến. Không cần đăng nhập.</p>
        <br>
        <a class="link-big" href="<%= request.getContextPath() %><%= home != null ? home : "/chung/LoginView0.jsp" %>">Dành cho nhân viên</a>
        <p class="line muted small" style="margin-top:-6px;"><%= s != null ? "Đang đăng nhập: " + Format0.h(s.getFullName()) + ". Vào trang chủ." : "Nhân viên quản lý, nhân viên kho, nhân viên bán hàng đăng nhập để làm việc." %></p>
    </div>
</div>
</body>
</html>

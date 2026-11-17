<%-- Man hinh dang nhap chung cho moi nhan vien (goi view.chung). --%>
<%
    String err = (String) request.getAttribute("error");
    String username = Format0.trim(request.getParameter("username"));
    if (err == null && request.getParameter("need") != null) err = "Vui lòng đăng nhập bằng tài khoản có quyền truy cập chức năng này.";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng nhập</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>
<body class="solo">
<div class="screen s">
    <div class="screen-title">Đăng nhập</div>
    <div class="screen-body">
        <% if (err != null) { %><div class="alert err"><%= Format0.h(err) %></div><% } %>
        <form method="post" action="<%= request.getContextPath() %>/chung/doLogin0.jsp">
            <div class="form-row">
                <label for="username">Tên đăng nhập:</label>
                <input type="text" id="username" name="username" value="<%= Format0.h(username) %>" autofocus required>
            </div>
            <div class="form-row">
                <label for="password">Mật khẩu:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <div class="actions">
                <button class="btn" type="submit">Đăng nhập</button>
                <a class="btn" href="<%= request.getContextPath() %>/">Về trang đầu</a>
            </div>
        </form>
        <div class="demo-accounts">
            Tài khoản dùng thử (mật khẩu 123456): <b>quanly</b> – nhân viên quản lý · <b>kho</b> – nhân viên kho · <b>banhang</b> – nhân viên bán hàng
        </div>
    </div>
</div>
</body>
</html>

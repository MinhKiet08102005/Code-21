<%-- Xu ly dang nhap, phan luong theo vai tro. --%>
<%
    String username = Format0.trim(request.getParameter("username"));
    String password = request.getParameter("password");
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect(request.getContextPath() + "/chung/LoginView0.jsp");
        return;
    }
    if (username.isEmpty() || Format0.blank(password)) {
        request.setAttribute("error", "Vui lòng nhập tên đăng nhập và mật khẩu.");
        request.getRequestDispatcher("/chung/LoginView0.jsp").forward(request, response);
        return;
    }
    Staff0 staff = new UserDAO0().checkLogin(username, password);
    if (staff == null) {
        request.setAttribute("error", "Sai tên đăng nhập hoặc mật khẩu.");
        request.getRequestDispatcher("/chung/LoginView0.jsp").forward(request, response);
        return;
    }
    session.setAttribute("staff", staff);
    String home;
    if ("MANAGER".equals(staff.getRole())) home = "/quanly/ManagerHomeView0.jsp";
    else if ("WAREHOUSE".equals(staff.getRole())) home = "/kho/WarehouseHomeView0.jsp";
    else home = "/banhang/SaleHomeView0.jsp";
    response.sendRedirect(request.getContextPath() + home);
%>

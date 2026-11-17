<%@ page isErrorPage="true" %>
<%
    Throwable err = exception != null ? exception : (Throwable) request.getAttribute("jakarta.servlet.error.exception");
    String msg = err == null ? "Không rõ nguyên nhân" : (err.getMessage() == null ? err.toString() : err.getMessage());
    if (err != null) err.printStackTrace();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thông báo</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>
<body class="solo">
<div class="screen s">
    <div class="screen-title">Thông báo</div>
    <div class="screen-body">
        <p class="line">Có lỗi xảy ra.</p>
        <p class="line"><%= Format0.h(msg) %></p>
        <div class="actions">
            <a class="btn" href="javascript:history.back()">Quay lại</a>
            <a class="btn" href="<%= request.getContextPath() %>/">Trang đầu</a>
        </div>
    </div>
</div>
</body>
</html>

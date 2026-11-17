<%-- Xu ly xoa mon an (use case Xoa mon an). --%>
<% String REQUIRED_ROLE = "MANAGER"; %>
<%@ include file="/common/guard.jspf" %>
<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        DishDAO0 dishDAO = new DishDAO0();
        Dish0 dish = dishDAO.getDishById(Format0.parseInt(request.getParameter("id"), 0));
        if (dish == null) {
            session.setAttribute("flashErr", "Không tìm thấy món ăn.");
        } else {
            int r = dishDAO.deleteDish(dish.getId());
            if (r == 1) session.setAttribute("flashOk", "Đã xóa món " + dish.getName() + ".");
            else if (r == 2) session.setAttribute("flashOk", "Món " + dish.getName()
                    + " đã có trong đơn gọi món hoặc combo nên không xóa được, đã chuyển sang trạng thái Ngừng bán.");
            else session.setAttribute("flashErr", "Không xóa được món ăn, vui lòng thử lại.");
        }
    }
    response.sendRedirect(request.getContextPath() + "/quanly/ManageDishView0.jsp");
%>

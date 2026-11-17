<%-- Xu ly them / sua so luong / bo mon trong don goi mon tai ban. --%>
<% String REQUIRED_ROLE = "SALE"; %>
<%@ include file="/common/guard.jspf" %>
<%
    Order0 order = new OrderDAO0().getOrderById(Format0.parseInt(request.getParameter("orderId"), 0));
    if (!"POST".equalsIgnoreCase(request.getMethod()) || order == null) {
        response.sendRedirect(request.getContextPath() + "/banhang/TakeOrderView0.jsp");
        return;
    }
    String back = request.getContextPath() + "/banhang/TakeOrderView0.jsp?table=" + (order.getTable() == null ? 0 : order.getTable().getId());
    if (!OrderDAO0.SERVING.equals(order.getStatus())) {
        session.setAttribute("flashErr", "Đơn " + order.getCode() + " không còn ở trạng thái đang phục vụ.");
        response.sendRedirect(back);
        return;
    }
    OrderDetailDAO0 detailDAO = new OrderDetailDAO0();
    String action = request.getParameter("action");
    int qty = Format0.parseInt(request.getParameter("qty"), 0);
    try {
        if ("add".equals(action)) {
            if (qty < 1 || qty > 50) throw new IllegalArgumentException("Số lượng phải từ 1 đến 50.");
            OrderDetail0 d = new OrderDetail0();
            d.setOrderId(order.getId());
            d.setQuantity(qty);
            int itemId = Format0.parseInt(request.getParameter("itemId"), 0);
            if ("combo".equals(request.getParameter("type"))) {
                Combo0 c = new ComboDAO0().getComboById(itemId);
                if (c == null || !DishDAO0.AVAILABLE.equals(c.getStatus())) throw new IllegalArgumentException("Combo đã ngừng bán.");
                d.setCombo(c);
                d.setUnitPrice(c.getPrice());
            } else {
                Dish0 dish = new DishDAO0().getDishById(itemId);
                if (dish == null || !DishDAO0.AVAILABLE.equals(dish.getStatus())) throw new IllegalArgumentException("Món đã hết hoặc ngừng bán, không thêm vào đơn được.");
                d.setDish(dish);
                d.setUnitPrice(dish.getSellingPrice());
            }
            detailDAO.addDetail(d);
            session.setAttribute("flashOk", "Đã thêm " + qty + " × " + d.getItemName() + ".");
        } else if ("update".equals(action)) {
            if (qty < 1 || qty > 50) throw new IllegalArgumentException("Số lượng phải từ 1 đến 50.");
            detailDAO.updateQuantity(Format0.parseInt(request.getParameter("detailId"), 0), qty);
        } else if ("remove".equals(action)) {
            detailDAO.deleteDetail(Format0.parseInt(request.getParameter("detailId"), 0));
            session.setAttribute("flashOk", "Đã bỏ món khỏi đơn.");
        }
    } catch (IllegalArgumentException e) {
        session.setAttribute("flashErr", e.getMessage());
    } catch (java.sql.SQLException e) {
        session.setAttribute("flashErr", "Không cập nhật được đơn, vui lòng thử lại.");
    }
    response.sendRedirect(back);
%>

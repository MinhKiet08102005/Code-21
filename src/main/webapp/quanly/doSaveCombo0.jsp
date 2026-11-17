<%-- Xu ly luu combo moi / doi trang thai combo. --%>
<% String REQUIRED_ROLE = "MANAGER"; %>
<%@ include file="/common/guard.jspf" %>
<%
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect(request.getContextPath() + "/quanly/ManageComboView0.jsp");
        return;
    }
    ComboDAO0 comboDAO = new ComboDAO0();
    if ("toggle".equals(request.getParameter("action"))) {
        Combo0 c = comboDAO.getComboById(Format0.parseInt(request.getParameter("id"), 0));
        if (c != null) {
            String st = DishDAO0.AVAILABLE.equals(c.getStatus()) ? DishDAO0.STOPPED : DishDAO0.AVAILABLE;
            if (comboDAO.updateStatus(c.getId(), st)) session.setAttribute("flashOk", "Combo " + c.getName() + ": " + st + ".");
        }
        response.sendRedirect(request.getContextPath() + "/quanly/ManageComboView0.jsp");
        return;
    }

    String name = Format0.trim(request.getParameter("txtName"));
    String priceText = request.getParameter("txtPrice");
    BigDecimal price = Format0.parseNumber(priceText);
    Map<String, String> errors = new LinkedHashMap<>();
    Combo0 combo = new Combo0();
    for (Dish0 d : new DishDAO0().searchDish("")) {
        int q = Format0.parseInt(request.getParameter("qty_" + d.getId()), 0);
        if (q > 0) {
            ComboDetail0 cd = new ComboDetail0();
            cd.setDish(d);
            cd.setQuantity(q);
            combo.getDetails().add(cd);
        }
    }
    if (name.isEmpty()) errors.put("name", "Vui lòng nhập tên combo");
    else if (comboDAO.checkDuplicateName(name)) errors.put("name", "Tên combo đã tồn tại");
    if (combo.getDetails().size() < 2) errors.put("items", "Combo phải gồm ít nhất 2 món khác nhau");
    if (Format0.blank(priceText)) errors.put("price", "Vui lòng nhập giá combo");
    else if (price == null || price.signum() <= 0) errors.put("price", "Giá combo phải là số dương");
    else if (!combo.getDetails().isEmpty() && price.compareTo(combo.getOriginalPrice()) >= 0)
        errors.put("price", "Giá combo phải thấp hơn tổng giá mua lẻ (" + Format0.money(combo.getOriginalPrice()) + ")");
    if (errors.isEmpty()) {
        combo.setName(name);
        combo.setPrice(price);
        combo.setDescription(Format0.nullIfBlank(request.getParameter("txtDescription")));
        combo.setCreatedBy((ManagementStaff0) currentStaff);
        if (comboDAO.addCombo(combo)) {
            session.setAttribute("flashOk", "Đã lập combo " + combo.getCode() + " – " + combo.getName() + ".");
            response.sendRedirect(request.getContextPath() + "/quanly/ManageComboView0.jsp?new=" + combo.getId());
            return;
        }
        errors.put("general", "Không lưu được combo, vui lòng thử lại.");
    }
    request.setAttribute("errors", errors);
    request.getRequestDispatcher("/quanly/AddComboView0.jsp").forward(request, response);
%>

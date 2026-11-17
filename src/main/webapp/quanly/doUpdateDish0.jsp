<%-- Xu ly sua mon an. --%>
<%@ page import="jakarta.servlet.http.Part, util.ImageUpload0" %>
<% String REQUIRED_ROLE = "MANAGER"; %>
<%@ include file="/common/guard.jspf" %>
<%
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect(request.getContextPath() + "/quanly/ManageDishView0.jsp");
        return;
    }
    DishDAO0 dishDAO = new DishDAO0();
    Dish0 dish = dishDAO.getDishById(Format0.parseInt(request.getParameter("id"), 0));
    if (dish == null) {
        session.setAttribute("flashErr", "Không tìm thấy món ăn.");
        response.sendRedirect(request.getContextPath() + "/quanly/ManageDishView0.jsp");
        return;
    }
    String name = Format0.trim(request.getParameter("txtDishName"));
    DishCategory0 category = new DishCategoryDAO0().getCategoryById(Format0.parseInt(request.getParameter("cboCategory"), 0));
    String priceText = request.getParameter("txtSellingPrice");
    BigDecimal price = Format0.parseNumber(priceText);
    String status = DishDAO0.STOPPED.equals(request.getParameter("cboStatus")) ? DishDAO0.STOPPED : DishDAO0.AVAILABLE;
    Part image = request.getPart("fileImage");

    Map<String, String> errors = new LinkedHashMap<>();
    if (name.isEmpty()) errors.put("name", "Vui lòng nhập tên món ăn");
    else if (dishDAO.checkDuplicateName(name, dish.getId())) errors.put("name", "Tên món ăn đã tồn tại, vui lòng nhập tên khác");
    if (category == null) errors.put("category", "Vui lòng chọn danh mục");
    if (Format0.blank(priceText)) errors.put("price", "Vui lòng nhập giá bán");
    else if (price == null || price.signum() <= 0) errors.put("price", "Giá bán phải là số dương");
    String imgErr = ImageUpload0.validate(image);
    if (imgErr != null) errors.put("image", imgErr);
    if (!errors.isEmpty()) {
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("/quanly/EditDishView0.jsp").forward(request, response);
        return;
    }
    String uploadRoot = application.getRealPath("/uploads");
    String oldImage = dish.getImagePath();
    dish.setName(name);
    dish.setCategory(category);
    dish.setSellingPrice(price);
    dish.setDescription(Format0.nullIfBlank(request.getParameter("txtDescription")));
    dish.setStatus(status);
    if (ImageUpload0.hasFile(image)) dish.setImagePath(ImageUpload0.save(image, uploadRoot));
    if (dishDAO.updateDish(dish)) {
        if (ImageUpload0.hasFile(image)) ImageUpload0.deleteQuietly(uploadRoot, oldImage);
        session.setAttribute("flashOk", "Đã cập nhật món ăn " + dish.getCode() + " – " + dish.getName() + ".");
        response.sendRedirect(request.getContextPath() + "/quanly/ManageDishView0.jsp?new=" + dish.getId());
    } else {
        if (ImageUpload0.hasFile(image)) ImageUpload0.deleteQuietly(uploadRoot, dish.getImagePath());
        request.setAttribute("errors", errors);
        request.setAttribute("generalError", "Không lưu được, vui lòng thử lại.");
        request.getRequestDispatcher("/quanly/EditDishView0.jsp").forward(request, response);
    }
%>

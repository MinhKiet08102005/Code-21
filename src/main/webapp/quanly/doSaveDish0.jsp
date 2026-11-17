<%-- Xu ly luu mon an moi. Thiet ke: -dish : Dish0, -message : String. Phu thuoc DishDAO0. --%>
<%@ page import="jakarta.servlet.http.Part, util.ImageUpload0" %>
<% String REQUIRED_ROLE = "MANAGER"; String PAGE_TITLE = "Thêm món ăn mới"; String MENU = "dish"; String SIZE = "m"; %>
<%@ include file="/common/guard.jspf" %>
<%
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect(request.getContextPath() + "/quanly/AddDishView0.jsp");
        return;
    }
    String name = Format0.trim(request.getParameter("txtDishName"));
    int idCategory = Format0.parseInt(request.getParameter("cboCategory"), 0);
    String priceText = request.getParameter("txtSellingPrice");
    String description = Format0.nullIfBlank(request.getParameter("txtDescription"));
    Part image = request.getPart("fileImage");

    // Kiem tra du lieu (ngoai le 5.1, 5.2, 6.1, 6.2 cua kich ban)
    Map<String, String> errors = new LinkedHashMap<>();
    DishDAO0 dishDAO = new DishDAO0();
    DishCategory0 category = new DishCategoryDAO0().getCategoryById(idCategory);
    if (name.isEmpty()) errors.put("name", "Vui lòng nhập tên món ăn");
    if (category == null) errors.put("category", "Vui lòng chọn danh mục");
    BigDecimal price = Format0.parseNumber(priceText);
    if (Format0.blank(priceText)) errors.put("price", "Vui lòng nhập giá bán");
    else if (price == null || price.signum() <= 0) errors.put("price", "Giá bán phải là số dương");
    String imgErr = ImageUpload0.validate(image);
    if (imgErr != null) errors.put("image", imgErr);
    if (!errors.containsKey("name") && dishDAO.checkDuplicateName(name))
        errors.put("name", "Tên món ăn đã tồn tại, vui lòng nhập tên khác");
    if (!errors.isEmpty()) {
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("/quanly/AddDishView0.jsp").forward(request, response);
        return;
    }

    String uploadRoot = application.getRealPath("/uploads");
    Dish0 dish = new Dish0();
    dish.setName(name);
    dish.setCategory(category);
    dish.setSellingPrice(price);
    dish.setDescription(description);
    dish.setStatus(DishDAO0.AVAILABLE);
    dish.setCreatedBy((ManagementStaff0) currentStaff);
    if (ImageUpload0.hasFile(image)) dish.setImagePath(ImageUpload0.save(image, uploadRoot));

    if (!dishDAO.addDish(dish)) {
        // Ngoai le 7.1: loi CSDL -> huy thao tac ghi, giu nguyen du lieu tren form
        ImageUpload0.deleteQuietly(uploadRoot, dish.getImagePath());
        request.setAttribute("generalError", "Không lưu được, vui lòng thử lại.");
        request.getRequestDispatcher("/quanly/AddDishView0.jsp").forward(request, response);
        return;
    }
    %>
<% request.setAttribute("screenTitle", "Thông báo"); %>
<%@ include file="/common/header.jspf" %>
<p class="line">Thêm món ăn thành công.</p>
<p class="line">Mã món ăn: <%= Format0.h(dish.getCode()) %></p>
<p class="line muted small"><%= Format0.h(dish.getName()) %> · <%= Format0.h(category.getName()) %> · <%= Format0.money(dish.getSellingPrice()) %></p>
<div class="actions">
    <a class="btn" href="<%= ctxPath %>/quanly/ManageDishView0.jsp?new=<%= dish.getId() %>">OK</a>
</div>
<%@ include file="/common/footer.jspf" %>

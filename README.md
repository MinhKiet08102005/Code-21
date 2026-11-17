# Demo – Hệ thống quản lí nhà hàng (Đề 21 – B23DCCE060)

Cài đặt đầy đủ theo pha thiết kế. Kiến trúc ba tầng **view (JSP) → dao → model**, đúng sơ đồ gói. Tên lớp tiếng Anh có hậu tố `0`, giống sơ đồ lớp thiết kế chi tiết.

## 1. Chạy demo

Yêu cầu: JDK 17 trở lên và Maven. Trên máy này đã có JDK 21 và Maven 3.9.

1. Nhấp đúp **`run.bat`**, hoặc chạy lệnh `mvn compile exec:java` trong thư mục `demo`.
2. Lần đầu Maven tải thư viện (Tomcat, H2, MySQL driver), mất khoảng 1–2 phút. Sau đó trình duyệt tự mở **http://localhost:8080**.
3. Nếu cổng 8080 bận, chương trình tự chọn cổng kế tiếp và in ra màn hình.
4. Dừng: nhấn `Ctrl + C` trong cửa sổ đang chạy.

Tài khoản dùng thử, mật khẩu đều là `123456`:

| Tài khoản | Vai trò |
|---|---|
| `quanly` | Nhân viên quản lí |
| `kho` | Nhân viên kho |
| `banhang`, `banhang2` | Nhân viên bán hàng |
| Không cần đăng nhập | Khách hàng: vào trang đầu → "Dành cho khách hàng" |

Muốn quay về dữ liệu mẫu ban đầu: tắt ứng dụng, chạy `reset_data.bat`.

### Dùng MySQL 8 thay cho H2

Mặc định ứng dụng dùng **H2 nhúng** ở chế độ tương thích MySQL, lưu trong thư mục `data/`. Chạy được ngay, không cần cài gì thêm. Muốn dùng MySQL thật:

1. Chạy `database/create_database_mysql.sql`.
2. Trong `src/main/resources/db.properties`, đổi `db.url`, `db.user`, `db.password` sang MySQL. Mẫu có sẵn trong file.
3. Chạy `run.bat`. Lần đầu ứng dụng tự tạo bảng (`schema.sql`) và nạp dữ liệu mẫu (`data.sql`).

## 1b. Giao diện

Giao diện làm đúng theo file **"pha thiết kế giao diện.docx"**: mỗi màn hình là một khung viền đen, thanh tiêu đề xanh nhạt ở giữa, nhãn nằm bên trái ô nhập, dấu **(*)** đỏ cho trường bắt buộc, bảng lưới đen, nút xanh nhạt viền đen. 12 màn hình của hai module có tiêu đề, nhãn, tên cột và tên nút trùng với hình mẫu:

| Module | Màn hình (trang JSP) |
|---|---|
| Thêm món ăn mới | Trang chủ nhân viên quản lý · Danh sách món ăn · Form thêm món ăn mới · Thông báo kết quả |
| Nhập nguyên liệu | Trang chủ nhân viên kho · Tìm nhà cung cấp · Thêm nhà cung cấp mới · Lập phiếu nhập nguyên liệu · Nhập số lượng nguyên liệu · Thêm nguyên liệu mới · Xác nhận phiếu nhập · Thông báo kết quả |

Các chức năng còn lại (combo, thống kê, bán hàng, khách hàng) dùng cùng kiểu khung. Ảnh chụp các màn hình nằm trong `docs/screenshots/`. Phía trên mỗi khung có một dòng chữ nhỏ: tên nhân viên, các liên kết chuyển chức năng và nút Đăng xuất.

## 2. Cấu trúc thư mục

```
demo/
├── run.bat, reset_data.bat     chạy demo / xóa dữ liệu thử
├── pom.xml                     cấu hình Maven (đóng gói được file .war để deploy lên Tomcat)
├── database/                   CSDL
│   ├── schema.sql              lược đồ 21 bảng tblXxx0 (khóa chính, khóa ngoại, ràng buộc duy nhất)
│   ├── data.sql                dữ liệu mẫu, trùng với kịch bản trong báo cáo
│   └── create_database_mysql.sql
├── src/main/java/
│   ├── model/                  tầng thực thể – 20 lớp theo sơ đồ gói + 4 lớp thống kê
│   ├── dao/                    tầng truy xuất dữ liệu – DAO0 (kết nối dùng chung) + 16 lớp DAO
│   ├── util/                   Format0 (định dạng tiền, ngày, kiểm tra dữ liệu), ImageUpload0
│   └── app/Launcher.java       khởi động Tomcat nhúng (chỉ để chạy demo, không thuộc thiết kế)
├── src/main/resources/db.properties   cấu hình kết nối CSDL
└── src/main/webapp/            tầng giao diện (JSP)
    ├── common/                 khung trang, menu theo vai trò, kiểm tra đăng nhập, trang lỗi
    ├── chung/                  đăng nhập, đăng xuất
    ├── quanly/                 nhân viên quản lí
    ├── kho/                    nhân viên kho
    ├── banhang/                nhân viên bán hàng
    ├── khachhang/              khách hàng
    ├── assets/css/style.css    giao diện
    └── uploads/                ảnh món ăn tải lên
```

## 3. Chức năng theo vai trò

| Vai trò | Trang JSP | Chức năng |
|---|---|---|
| Chung | `LoginView0`, `doLogin0`, `doLogout0` | Đăng nhập, phân luồng theo vai trò, đăng xuất |
| Quản lí | `ManagerHomeView0` | Trang chủ, số liệu nhanh |
| | `ManageDishView0`, `AddDishView0`, `doSaveDish0`, `EditDishView0`, `doUpdateDish0`, `doDeleteDish0` | **Module 1 – Quản lí thông tin món ăn**: xem, thêm món mới (có ảnh), sửa, xóa |
| | `ManageComboView0`, `AddComboView0`, `doSaveCombo0` | Lập thực đơn combo |
| | `StatisticView0` | Thống kê món ăn, nguyên liệu, khách hàng, nhà cung cấp; xem phiếu nhập của từng nhà cung cấp |
| Kho | `WarehouseHomeView0` | Trang chủ, nguyên liệu sắp hết, phiếu gần đây |
| | `SearchSupplierView0`, `AddSupplierView0`, `ImportIngredientView0`, `EnterQuantityView0`, `AddIngredientView0`, `ConfirmImportView0`, `doSaveImport0`, `PrintImportInvoiceView0` | **Module 2 – Nhập nguyên liệu**: tìm / thêm nhà cung cấp, tìm / thêm nguyên liệu, nhập số lượng, xác nhận, lưu, in phiếu (in lại được) |
| | `SearchSupplierView0?mode=manage`, `EditSupplierView0` | Quản lí thông tin nhà cung cấp (thêm, sửa, xóa) |
| | `ImportInvoiceListView0` | Danh sách phiếu nhập |
| Bán hàng | `SaleHomeView0` | Sơ đồ bàn, việc cần xử lí |
| | `ReceiveCustomerView0` | Tiếp nhận khách vãng lai / khách đã đặt bàn, xếp bàn |
| | `TakeOrderView0`, `doSaveOrder0` | Ghi nhận gọi món (món lẻ, combo) |
| | `PaymentView0` | Thanh toán tại bàn, giảm giá thẻ thành viên, in hóa đơn |
| | `MembershipCardView0` | Lập thẻ thành viên |
| | `ConfirmReservationView0` | Xác nhận / từ chối đặt bàn và đơn đặt món trực tuyến |
| Khách hàng | `SearchDishView0` | Tìm kiếm món ăn, combo, xem chi tiết |
| | `BookTableView0`, `doSaveReservation0` | Đặt bàn trực tuyến, tra cứu theo số điện thoại |
| | `OnlineOrderView0` | Đặt món trực tuyến (giỏ món), tra cứu đơn |

## 4. Bám sát thiết kế

- **Hai module đã thiết kế chi tiết** giữ đúng tên trang JSP, tên thuộc tính giao diện (`txtDishName`, `cboCategory`, `txtSellingPrice`, `fileImage`, `txtSupplierName`, `txtQuantity`...) và chữ ký phương thức DAO:
  - `DishDAO0`: `getDishList()`, `checkDuplicateName(String)`, `addDish(Dish0)`.
  - `DishCategoryDAO0`: `getCategories()`.
  - `SupplierDAO0`: `searchSupplier(String)`, `addSupplier(Supplier0)`.
  - `IngredientDAO0`: `searchIngredient(String)`, `addIngredient(Ingredient0)`, `updateStock(int, BigDecimal)`.
  - `ImportDetailDAO0`: `addDetail(ImportDetail0)`, `getDetailByInvoice(int)`.
  - `ImportInvoiceDAO0`: `calculateTotal(List)`, `saveImportInvoice(ImportInvoice0)`, `printInvoice(int)`.
- **`DAO0`** giữ một kết nối dùng chung cho mọi lớp DAO con.
- **Lưu phiếu nhập** (phiếu, các dòng chi tiết, cộng tồn kho) chạy trong **một giao dịch**. Lỗi ở bất kỳ bước nào thì hủy toàn bộ.
- **Các ngoại lệ trong kịch bản đều được xử lí:**
  - **Module 1:**
    - Thiếu trường bắt buộc.
    - Ảnh không phải JPG/PNG hoặc lớn hơn 2MB.
    - Trùng tên món.
    - Giá bán không phải số dương.
    - Lỗi lưu CSDL.
    - Hủy trước khi lưu.
  - **Module 2:**
    - Không tìm thấy nhà cung cấp hoặc nguyên liệu (cho thêm mới).
    - Số lượng hoặc đơn giá không hợp lệ.
    - Nguyên liệu đã có trong phiếu (cộng dồn).
    - Danh sách nhập rỗng.
    - Sửa số lượng theo hàng thực nhận.
    - Lỗi CSDL thì hủy giao dịch.
    - In lỗi thì in lại cùng phiếu.
    - Hủy phiếu.
- Mật khẩu lưu dạng SHA-256. Mỗi trang kiểm tra đăng nhập và vai trò trước khi hiển thị.

## 5. Gợi ý chạy thử theo kịch bản báo cáo

1. **Module 1:**
   - Đăng nhập `quanly` → Quản lí thông tin món ăn → Thêm mới.
   - Nhập "Bò lúc lắc", Món chính, 150000, chọn ảnh JPG/PNG → Lưu.
   - Kết quả: "Thêm món ăn thành công – Mã món: MA015".
2. **Module 2:**
   - Đăng nhập `kho` → Nhập nguyên liệu → tìm "Thực phẩm Xanh" → Chọn Công ty Thực phẩm Xanh.
   - Tìm "Thịt bò" → Chọn Thịt bò thăn → 10 kg × 280000 → thêm tiếp nguyên liệu khác.
   - Xác nhận → Xác nhận lưu phiếu → "Nhập kho thành công – Mã phiếu: PN0102" → In phiếu nhập.
3. **Bán hàng:**
   - Đăng nhập `banhang` → Tiếp nhận khách → Ghi nhận gọi món.
   - Thanh toán, nhập số điện thoại 0987654321 để được giảm 10% thẻ Vàng.

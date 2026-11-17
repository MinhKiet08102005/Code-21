-- Du lieu mau cho demo. Mat khau cua tat ca tai khoan: 123456 (luu dang SHA-256).
-- Mot so du lieu trung voi kich ban trong bao cao (MA001 Pho bo tai, NCC001 Cong ty Thuc pham Xanh,
-- NL003 Thit bo than...) de chay thu dung theo kich ban.

INSERT INTO tblUser0 (username, passwordHash, fullName, email, phone) VALUES
('quanly',   '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn An',   'an.nv@nhahang.vn',    '0901111001'),
('kho',      '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thị Bình',   'binh.tt@nhahang.vn',  '0901111002'),
('banhang',  '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Văn Cường',    'cuong.lv@nhahang.vn', '0901111003'),
('banhang2', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Dung',   'dung.pt@nhahang.vn',  '0901111004');

INSERT INTO tblStaff0 (id, position) VALUES (1, 'Nhân viên quản lý'), (2, 'Nhân viên kho'), (3, 'Nhân viên bán hàng'), (4, 'Nhân viên bán hàng');
INSERT INTO tblManagementStaff0 (id) VALUES (1);
INSERT INTO tblWarehouseStaff0 (id) VALUES (2);
INSERT INTO tblSaleStaff0 (id) VALUES (3), (4);

INSERT INTO tblDishCategory0 (name, description) VALUES
('Khai vị', 'Các món ăn nhẹ trước bữa chính'),
('Món chính', 'Các món ăn chính của bữa'),
('Tráng miệng', 'Các món ngọt sau bữa ăn'),
('Đồ uống', 'Nước giải khát, trà, cà phê');

INSERT INTO tblDish0 (code, name, sellingPrice, description, imagePath, status, idCategory, idCreatedBy) VALUES
('MA001', 'Phở bò tái', 65000, 'Phở bò tái nước dùng hầm xương 12 tiếng', NULL, 'Đang bán', 2, 1),
('MA002', 'Gỏi cuốn tôm thịt', 45000, 'Gỏi cuốn tôm, thịt heo, bún, rau sống, chấm tương đậu', NULL, 'Đang bán', 1, 1),
('MA003', 'Chè khúc bạch', 35000, 'Chè khúc bạch hạnh nhân, vải thiều', NULL, 'Đang bán', 3, 1),
('MA004', 'Chả giò hải sản', 55000, 'Chả giò nhân tôm mực, chiên giòn', NULL, 'Đang bán', 1, 1),
('MA005', 'Súp cua', 40000, 'Súp cua trứng bắc thảo', NULL, 'Đang bán', 1, 1),
('MA006', 'Cơm tấm sườn bì chả', 60000, 'Cơm tấm sườn nướng, bì, chả trứng', NULL, 'Đang bán', 2, 1),
('MA007', 'Bún chả Hà Nội', 55000, 'Bún chả nướng than hoa, nước chấm chua ngọt', NULL, 'Đang bán', 2, 1),
('MA008', 'Lẩu thái hải sản', 320000, 'Lẩu thái chua cay cho 3-4 người', NULL, 'Đang bán', 2, 1),
('MA009', 'Gà nướng mật ong', 180000, 'Nửa con gà ta nướng mật ong', NULL, 'Đang bán', 2, 1),
('MA010', 'Bánh flan', 25000, 'Bánh flan caramen', NULL, 'Đang bán', 3, 1),
('MA011', 'Trà đào cam sả', 35000, 'Trà đào, cam, sả tươi', NULL, 'Đang bán', 4, 1),
('MA012', 'Nước ép cam', 30000, 'Cam sành ép nguyên chất', NULL, 'Đang bán', 4, 1),
('MA013', 'Cà phê sữa đá', 25000, 'Cà phê phin pha sữa đặc', NULL, 'Đang bán', 4, 1),
('MA014', 'Bò kho bánh mì', 60000, 'Bò kho sả quế, ăn kèm bánh mì', NULL, 'Ngừng bán', 2, 1);

INSERT INTO tblCombo0 (code, name, price, description, status, idCreatedBy) VALUES
('CB001', 'Combo gia đình 4 người', 540000, 'Lẩu thái, gỏi cuốn, chả giò và trà đào cho 4 người', 'Đang bán', 1),
('CB002', 'Combo trưa văn phòng', 85000, 'Cơm tấm sườn bì chả kèm trà đào', 'Đang bán', 1),
('CB003', 'Combo đôi', 180000, 'Hai phở bò tái và hai chè khúc bạch', 'Đang bán', 1);

INSERT INTO tblComboDetail0 (quantity, idCombo, idDish) VALUES
(1, 1, 8), (2, 1, 2), (1, 1, 4), (4, 1, 11),
(1, 2, 6), (1, 2, 11),
(2, 3, 1), (2, 3, 3);

INSERT INTO tblSupplier0 (code, name, address, phone, email, description) VALUES
('NCC001', 'Công ty Thực phẩm Xanh', '123 Lê Lợi, Q.1, TP.HCM', '0901234567', 'lienhe@thucphamxanh.vn', 'Thịt, bánh phở, gạo'),
('NCC002', 'Hải sản Biển Đông', '45 Nguyễn Tất Thành, Q.4, TP.HCM', '0912345678', 'bandong@haisan.vn', 'Tôm, mực, cua'),
('NCC003', 'Rau sạch Đà Lạt', '12 Phù Đổng Thiên Vương, Đà Lạt', '0263382200', NULL, 'Rau, củ, trái cây'),
('NCC004', 'Công ty Đồ uống Sài Gòn', '88 Cách Mạng Tháng 8, Q.3, TP.HCM', '0283930001', 'sales@douongsg.vn', 'Cà phê, trà, sữa'),
('NCC005', 'Thực phẩm Xanh Đà Lạt', '45 Phù Đổng Thiên Vương, Đà Lạt', '0263382211', NULL, 'Rau củ hữu cơ');

INSERT INTO tblIngredient0 (code, name, unit, stockQuantity, description) VALUES
('NL001', 'Bánh phở', 'kg', 18, 'Bánh phở tươi'),
('NL002', 'Thịt heo', 'kg', 10, 'Thịt nạc vai'),
('NL003', 'Thịt bò thăn', 'kg', 12, NULL),
('NL004', 'Thịt bò bắp', 'kg', 8, NULL),
('NL005', 'Tôm sú', 'kg', 6, NULL),
('NL006', 'Mực ống', 'kg', 5, NULL),
('NL007', 'Rau thơm các loại', 'kg', 7, 'Húng, ngò, tía tô'),
('NL008', 'Hành tây', 'kg', 9, NULL),
('NL009', 'Gạo tấm', 'kg', 40, NULL),
('NL010', 'Trứng gà', 'quả', 120, NULL),
('NL011', 'Sữa đặc', 'hộp', 24, NULL),
('NL012', 'Đào ngâm', 'hộp', 15, NULL),
('NL013', 'Cam sành', 'kg', 20, NULL),
('NL014', 'Cà phê hạt', 'kg', 4, 'Robusta rang mộc');

INSERT INTO tblImportInvoice0 (code, importDate, totalAmount, idSupplier, idWarehouseStaff) VALUES
('PN0098', '2026-10-05 09:30:00', 8150000, 1, 2),
('PN0099', '2026-10-20 08:15:00', 5260000, 2, 2),
('PN0100', '2026-11-03 10:00:00', 1590000, 3, 2),
('PN0101', '2026-11-10 14:20:00', 7575000, 1, 2);

INSERT INTO tblImportDetail0 (quantity, unitPrice, amount, idImportInvoice, idIngredient) VALUES
(20, 280000, 5600000, 1, 3), (15, 120000, 1800000, 1, 2), (30, 25000, 750000, 1, 1),
(10, 350000, 3500000, 2, 5), (8, 220000, 1760000, 2, 6),
(12, 40000, 480000, 3, 7), (20, 18000, 360000, 3, 8), (25, 30000, 750000, 3, 13),
(15, 285000, 4275000, 4, 3), (10, 240000, 2400000, 4, 4), (50, 18000, 900000, 4, 9);

INSERT INTO tblDiningTable0 (code, tableNumber, capacity, location, status) VALUES
('B01', 1, 2, 'Tầng 1', 'Trống'),
('B02', 2, 2, 'Tầng 1', 'Trống'),
('B03', 3, 4, 'Tầng 1', 'Có khách'),
('B04', 4, 4, 'Tầng 1', 'Trống'),
('B05', 5, 6, 'Tầng 1', 'Trống'),
('B06', 6, 4, 'Tầng 2', 'Trống'),
('B07', 7, 4, 'Tầng 2', 'Trống'),
('B08', 8, 8, 'Tầng 2', 'Trống'),
('B09', 9, 2, 'Sân vườn', 'Trống'),
('B10', 10, 6, 'Sân vườn', 'Trống');

INSERT INTO tblCustomer0 (code, fullName, phone, email, address, birthDate) VALUES
('KH001', 'Nguyễn Thị Hoa', '0987654321', 'hoa.nt@gmail.com', '25 Trần Hưng Đạo, Q.1', '1992-04-12'),
('KH002', 'Trần Minh Quân', '0977111222', NULL, '10 Võ Văn Tần, Q.3', '1988-09-30'),
('KH003', 'Lê Thu Trang', '0966333444', 'trang.lt@gmail.com', NULL, '1999-01-05'),
('KH004', 'Phạm Đức Long', '0355777888', NULL, NULL, NULL),
('KH005', 'Võ Thị Mai', '0944555666', 'mai.vt@gmail.com', NULL, NULL),
('KH006', 'Đặng Văn Hùng', '0933222111', NULL, NULL, NULL);

INSERT INTO tblMembershipCard0 (code, issueDate, tier, points, idCustomer, idSaleStaff) VALUES
('TV0001', '2026-09-02', 'Vàng', 128, 1, 3),
('TV0002', '2026-10-10', 'Bạc', 45, 2, 3),
('TV0003', '2026-10-30', 'Bạc', 20, 3, 4);

INSERT INTO tblOrder0 (code, orderTime, status, orderType, note, idTable, idSaleStaff, idCustomer) VALUES
('DG0001', '2026-10-08 12:10:00', 'Đã thanh toán', 'Tại bàn', NULL, 2, 3, NULL),
('DG0002', '2026-10-15 19:00:00', 'Đã thanh toán', 'Tại bàn', NULL, 5, 3, 1),
('DG0003', '2026-10-28 12:30:00', 'Đã thanh toán', 'Tại bàn', NULL, 1, 4, NULL),
('DG0004', '2026-11-02 18:45:00', 'Đã thanh toán', 'Tại bàn', NULL, 7, 3, 2),
('DG0005', '2026-11-09 20:00:00', 'Đã thanh toán', 'Tại bàn', NULL, 8, 4, 1),
('DG0006', '2026-11-14 11:50:00', 'Đã thanh toán', 'Tại bàn', NULL, 4, 3, 3),
('DG0007', '2026-11-17 11:30:00', 'Đang phục vụ', 'Tại bàn', NULL, 3, 3, NULL),
('DG0008', '2026-11-17 09:15:00', 'Chờ xác nhận', 'Trực tuyến', 'Đến lấy lúc 12 giờ', NULL, NULL, 4);

INSERT INTO tblOrderDetail0 (quantity, unitPrice, amount, idOrder, idDish, idCombo) VALUES
(2, 65000, 130000, 1, 1, NULL), (2, 35000, 70000, 1, 11, NULL),
(1, 320000, 320000, 2, 8, NULL), (2, 45000, 90000, 2, 2, NULL), (3, 30000, 90000, 2, 12, NULL),
(2, 85000, 170000, 3, NULL, 2), (2, 25000, 50000, 3, 13, NULL),
(1, 180000, 180000, 4, 9, NULL), (2, 60000, 120000, 4, 6, NULL), (3, 35000, 105000, 4, 11, NULL),
(1, 540000, 540000, 5, NULL, 1), (4, 25000, 100000, 5, 10, NULL),
(2, 55000, 110000, 6, 7, NULL), (1, 55000, 55000, 6, 4, NULL), (2, 30000, 60000, 6, 12, NULL),
(2, 65000, 130000, 7, 1, NULL), (1, 45000, 45000, 7, 2, NULL),
(1, 180000, 180000, 8, NULL, 3), (2, 35000, 70000, 8, 11, NULL);

INSERT INTO tblPayment0 (code, paymentTime, totalAmount, discount, paymentMethod, idOrder, idSaleStaff, idCustomer) VALUES
('HD0001', '2026-10-08 13:05:00', 200000, 0, 'Tiền mặt', 1, 3, NULL),
('HD0002', '2026-10-15 20:30:00', 500000, 50000, 'Chuyển khoản', 2, 3, 1),
('HD0003', '2026-10-28 13:10:00', 220000, 0, 'Tiền mặt', 3, 4, NULL),
('HD0004', '2026-11-02 20:00:00', 405000, 20250, 'Thẻ ngân hàng', 4, 3, 2),
('HD0005', '2026-11-09 21:40:00', 640000, 64000, 'Chuyển khoản', 5, 4, 1),
('HD0006', '2026-11-14 12:45:00', 225000, 11250, 'Tiền mặt', 6, 3, 3);

INSERT INTO tblTableReservation0 (code, reservationTime, numberOfGuests, note, status, createdAt, idCustomer, idTable, idSaleStaff) VALUES
('DB0001', '2026-11-16 18:30:00', 2, NULL, 'Đã nhận bàn', '2026-11-15 10:00:00', 2, 2, 3),
('DB0002', '2026-11-18 19:00:00', 4, 'Gần cửa sổ nếu được', 'Chờ xác nhận', '2026-11-17 08:20:00', 5, NULL, NULL),
('DB0003', '2026-11-19 12:00:00', 6, 'Tổ chức sinh nhật', 'Chờ xác nhận', '2026-11-17 09:40:00', 6, NULL, NULL);

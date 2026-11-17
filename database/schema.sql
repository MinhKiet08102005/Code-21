-- He thong quan li nha hang - De 21 - B23DCCE060
-- Luoc do CSDL (MySQL 8; H2 chay o che do MODE=MySQL dung chung file nay).
-- Ten bang ket thuc bang so 0 theo quy uoc. Hai module da thiet ke chi tiet giu nguyen
-- cac bang cua so do CSDL bai 4; cac bang con lai mo rong cho toan he thong.

-- ===== Nguoi dung =====
CREATE TABLE tblUser0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  passwordHash VARCHAR(255) NOT NULL,
  fullName VARCHAR(100) NOT NULL,
  email VARCHAR(100) NULL,
  phone VARCHAR(20) NULL
);

CREATE TABLE tblStaff0 (
  id INT NOT NULL PRIMARY KEY,
  position VARCHAR(50) NOT NULL
);

CREATE TABLE tblManagementStaff0 (id INT NOT NULL PRIMARY KEY);
CREATE TABLE tblWarehouseStaff0 (id INT NOT NULL PRIMARY KEY);
CREATE TABLE tblSaleStaff0 (id INT NOT NULL PRIMARY KEY);

CREATE TABLE tblCustomer0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  fullName VARCHAR(100) NOT NULL,
  phone VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(100) NULL,
  address VARCHAR(255) NULL,
  birthDate DATE NULL
);

CREATE TABLE tblMembershipCard0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  issueDate DATE NOT NULL,
  tier VARCHAR(20) NOT NULL,
  points INT NOT NULL,
  idCustomer INT NOT NULL UNIQUE,
  idSaleStaff INT NOT NULL
);

-- ===== Thuc don =====
CREATE TABLE tblDishCategory0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(500) NULL
);

CREATE TABLE tblDish0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  sellingPrice DECIMAL(14,2) NOT NULL,
  description VARCHAR(500) NULL,
  imagePath VARCHAR(255) NULL,
  status VARCHAR(20) NOT NULL,
  idCategory INT NOT NULL,
  idCreatedBy INT NOT NULL
);

CREATE TABLE tblCombo0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(14,2) NOT NULL,
  description VARCHAR(500) NULL,
  status VARCHAR(20) NOT NULL,
  idCreatedBy INT NOT NULL
);

CREATE TABLE tblComboDetail0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  quantity INT NOT NULL,
  idCombo INT NOT NULL,
  idDish INT NOT NULL
);

-- ===== Kho =====
CREATE TABLE tblSupplier0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(100) NULL,
  description VARCHAR(500) NULL
);

CREATE TABLE tblIngredient0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  unit VARCHAR(20) NOT NULL,
  stockQuantity DECIMAL(12,3) NOT NULL,
  description VARCHAR(500) NULL
);

CREATE TABLE tblImportInvoice0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  importDate TIMESTAMP NOT NULL,
  totalAmount DECIMAL(14,2) NOT NULL,
  idSupplier INT NOT NULL,
  idWarehouseStaff INT NOT NULL
);

CREATE TABLE tblImportDetail0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  quantity DECIMAL(12,3) NOT NULL,
  unitPrice DECIMAL(14,2) NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  idImportInvoice INT NOT NULL,
  idIngredient INT NOT NULL
);

-- ===== Ban hang =====
CREATE TABLE tblDiningTable0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  tableNumber INT NOT NULL,
  capacity INT NOT NULL,
  location VARCHAR(100) NULL,
  status VARCHAR(20) NOT NULL
);

CREATE TABLE tblTableReservation0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  reservationTime TIMESTAMP NOT NULL,
  numberOfGuests INT NOT NULL,
  note VARCHAR(500) NULL,
  status VARCHAR(30) NOT NULL,
  createdAt TIMESTAMP NOT NULL,
  idCustomer INT NOT NULL,
  idTable INT NULL,
  idSaleStaff INT NULL
);

CREATE TABLE tblOrder0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  orderTime TIMESTAMP NOT NULL,
  status VARCHAR(30) NOT NULL,
  orderType VARCHAR(20) NOT NULL,
  note VARCHAR(500) NULL,
  idTable INT NULL,
  idSaleStaff INT NULL,
  idCustomer INT NULL
);

CREATE TABLE tblOrderDetail0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  quantity INT NOT NULL,
  unitPrice DECIMAL(14,2) NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  idOrder INT NOT NULL,
  idDish INT NULL,
  idCombo INT NULL
);

CREATE TABLE tblPayment0 (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  paymentTime TIMESTAMP NOT NULL,
  totalAmount DECIMAL(14,2) NOT NULL,
  discount DECIMAL(14,2) NOT NULL,
  paymentMethod VARCHAR(30) NOT NULL,
  idOrder INT NOT NULL UNIQUE,
  idSaleStaff INT NOT NULL,
  idCustomer INT NULL
);

-- ===== Khoa ngoai =====
ALTER TABLE tblStaff0 ADD CONSTRAINT fk_Staff_base FOREIGN KEY (id) REFERENCES tblUser0 (id);
ALTER TABLE tblManagementStaff0 ADD CONSTRAINT fk_ManagementStaff_base FOREIGN KEY (id) REFERENCES tblStaff0 (id);
ALTER TABLE tblWarehouseStaff0 ADD CONSTRAINT fk_WarehouseStaff_base FOREIGN KEY (id) REFERENCES tblStaff0 (id);
ALTER TABLE tblSaleStaff0 ADD CONSTRAINT fk_SaleStaff_base FOREIGN KEY (id) REFERENCES tblStaff0 (id);
ALTER TABLE tblMembershipCard0 ADD CONSTRAINT fk_Card_idCustomer FOREIGN KEY (idCustomer) REFERENCES tblCustomer0 (id);
ALTER TABLE tblMembershipCard0 ADD CONSTRAINT fk_Card_idSaleStaff FOREIGN KEY (idSaleStaff) REFERENCES tblSaleStaff0 (id);
ALTER TABLE tblDish0 ADD CONSTRAINT fk_Dish_idCategory FOREIGN KEY (idCategory) REFERENCES tblDishCategory0 (id);
ALTER TABLE tblDish0 ADD CONSTRAINT fk_Dish_idCreatedBy FOREIGN KEY (idCreatedBy) REFERENCES tblManagementStaff0 (id);
ALTER TABLE tblCombo0 ADD CONSTRAINT fk_Combo_idCreatedBy FOREIGN KEY (idCreatedBy) REFERENCES tblManagementStaff0 (id);
ALTER TABLE tblComboDetail0 ADD CONSTRAINT fk_ComboDetail_idCombo FOREIGN KEY (idCombo) REFERENCES tblCombo0 (id);
ALTER TABLE tblComboDetail0 ADD CONSTRAINT fk_ComboDetail_idDish FOREIGN KEY (idDish) REFERENCES tblDish0 (id);
ALTER TABLE tblComboDetail0 ADD CONSTRAINT uq_ComboDetail_pair UNIQUE (idCombo, idDish);
ALTER TABLE tblImportInvoice0 ADD CONSTRAINT fk_ImportInvoice_idSupplier FOREIGN KEY (idSupplier) REFERENCES tblSupplier0 (id);
ALTER TABLE tblImportInvoice0 ADD CONSTRAINT fk_ImportInvoice_idWarehouseStaff FOREIGN KEY (idWarehouseStaff) REFERENCES tblWarehouseStaff0 (id);
ALTER TABLE tblImportDetail0 ADD CONSTRAINT fk_ImportDetail_idImportInvoice FOREIGN KEY (idImportInvoice) REFERENCES tblImportInvoice0 (id);
ALTER TABLE tblImportDetail0 ADD CONSTRAINT fk_ImportDetail_idIngredient FOREIGN KEY (idIngredient) REFERENCES tblIngredient0 (id);
ALTER TABLE tblImportDetail0 ADD CONSTRAINT uq_ImportDetail_pair UNIQUE (idImportInvoice, idIngredient);
ALTER TABLE tblTableReservation0 ADD CONSTRAINT fk_Reservation_idCustomer FOREIGN KEY (idCustomer) REFERENCES tblCustomer0 (id);
ALTER TABLE tblTableReservation0 ADD CONSTRAINT fk_Reservation_idTable FOREIGN KEY (idTable) REFERENCES tblDiningTable0 (id);
ALTER TABLE tblTableReservation0 ADD CONSTRAINT fk_Reservation_idSaleStaff FOREIGN KEY (idSaleStaff) REFERENCES tblSaleStaff0 (id);
ALTER TABLE tblOrder0 ADD CONSTRAINT fk_Order_idTable FOREIGN KEY (idTable) REFERENCES tblDiningTable0 (id);
ALTER TABLE tblOrder0 ADD CONSTRAINT fk_Order_idSaleStaff FOREIGN KEY (idSaleStaff) REFERENCES tblSaleStaff0 (id);
ALTER TABLE tblOrder0 ADD CONSTRAINT fk_Order_idCustomer FOREIGN KEY (idCustomer) REFERENCES tblCustomer0 (id);
ALTER TABLE tblOrderDetail0 ADD CONSTRAINT fk_OrderDetail_idOrder FOREIGN KEY (idOrder) REFERENCES tblOrder0 (id);
ALTER TABLE tblOrderDetail0 ADD CONSTRAINT fk_OrderDetail_idDish FOREIGN KEY (idDish) REFERENCES tblDish0 (id);
ALTER TABLE tblOrderDetail0 ADD CONSTRAINT fk_OrderDetail_idCombo FOREIGN KEY (idCombo) REFERENCES tblCombo0 (id);
ALTER TABLE tblPayment0 ADD CONSTRAINT fk_Payment_idOrder FOREIGN KEY (idOrder) REFERENCES tblOrder0 (id);
ALTER TABLE tblPayment0 ADD CONSTRAINT fk_Payment_idSaleStaff FOREIGN KEY (idSaleStaff) REFERENCES tblSaleStaff0 (id);
ALTER TABLE tblPayment0 ADD CONSTRAINT fk_Payment_idCustomer FOREIGN KEY (idCustomer) REFERENCES tblCustomer0 (id);

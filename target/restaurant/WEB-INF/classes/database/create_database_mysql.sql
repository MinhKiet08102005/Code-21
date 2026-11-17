-- Chi dung khi chay voi MySQL 8 (H2 mac dinh khong can buoc nay).
-- 1) Chay file nay trong MySQL Workbench hoac: mysql -u root -p < create_database_mysql.sql
-- 2) Sua src/main/resources/db.properties: bo comment cac dong MySQL, dien mat khau.
-- 3) Chay run.bat. Lan dau ung dung tu tao bang (schema.sql) va nap du lieu mau (data.sql).
--    Hoac tu chay schema.sql roi data.sql trong database restaurant0.

CREATE DATABASE IF NOT EXISTS restaurant0 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

package dao;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.ManagementStaff0;
import model.SaleStaff0;
import model.Staff0;
import model.WarehouseStaff0;

/** Dang nhap nhan vien. */
public class UserDAO0 extends DAO0 {

    public UserDAO0() {
        super();
    }

    /** Tra ve nhan vien dung loai (quan li / kho / ban hang) hoac null neu sai tai khoan. */
    public Staff0 checkLogin(String username, String password) {
        String sql = "SELECT u.id, u.username, u.passwordHash, u.fullName, u.email, u.phone, s.position, "
                + "m.id AS mId, w.id AS wId, sa.id AS sId FROM tblUser0 u "
                + "JOIN tblStaff0 s ON s.id = u.id "
                + "LEFT JOIN tblManagementStaff0 m ON m.id = u.id "
                + "LEFT JOIN tblWarehouseStaff0 w ON w.id = u.id "
                + "LEFT JOIN tblSaleStaff0 sa ON sa.id = u.id "
                + "WHERE u.username = ? AND u.passwordHash = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, hashPassword(password));
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Staff0 s;
                if (rs.getObject("mId") != null) s = new ManagementStaff0();
                else if (rs.getObject("wId") != null) s = new WarehouseStaff0();
                else if (rs.getObject("sId") != null) s = new SaleStaff0();
                else return null;
                s.setId(rs.getInt("id"));
                s.setUsername(rs.getString("username"));
                s.setPasswordHash(rs.getString("passwordHash"));
                s.setFullName(rs.getString("fullName"));
                s.setEmail(rs.getString("email"));
                s.setPhone(rs.getString("phone"));
                s.setPosition(rs.getString("position"));
                return s;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** Ma hoa mat khau bang SHA-256 (chuoi hex). */
    public static String hashPassword(String password) {
        try {
            byte[] d = MessageDigest.getInstance("SHA-256").digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : d) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
}

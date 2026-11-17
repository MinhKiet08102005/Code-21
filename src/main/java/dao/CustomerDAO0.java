package dao;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Customer0;

/** Truy xuat khach hang. */
public class CustomerDAO0 extends DAO0 {

    public CustomerDAO0() {
        super();
    }

    static Customer0 map(ResultSet rs) throws SQLException {
        Customer0 c = new Customer0();
        c.setId(rs.getInt("id"));
        c.setCode(rs.getString("code"));
        c.setFullName(rs.getString("fullName"));
        c.setPhone(rs.getString("phone"));
        c.setEmail(rs.getString("email"));
        c.setAddress(rs.getString("address"));
        Date b = rs.getDate("birthDate");
        c.setBirthDate(b == null ? null : b.toLocalDate());
        return c;
    }

    public Customer0 getCustomerById(int id) {
        return one("SELECT * FROM tblCustomer0 WHERE id = ?", String.valueOf(id), true);
    }

    public Customer0 getCustomerByPhone(String phone) {
        return one("SELECT * FROM tblCustomer0 WHERE phone = ?", phone, false);
    }

    private Customer0 one(String sql, String v, boolean asInt) {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            if (asInt) ps.setInt(1, Integer.parseInt(v)); else ps.setString(1, v);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** Tim theo ten hoac so dien thoai. */
    public List<Customer0> searchCustomer(String keyword) {
        List<Customer0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM tblCustomer0 WHERE LOWER(fullName) LIKE ? OR phone LIKE ? ORDER BY fullName")) {
            String k = "%" + keyword.trim().toLowerCase() + "%";
            ps.setString(1, k);
            ps.setString(2, "%" + keyword.trim() + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    /** Them khach hang moi, gan id va ma KHxxx vao doi tuong. */
    public boolean addCustomer(Customer0 c) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblCustomer0 (code, fullName, phone, email, address, birthDate) VALUES (?,?,?,?,?,?)",
                Statement.RETURN_GENERATED_KEYS)) {
            c.setCode(nextCode("tblCustomer0", "KH", 3));
            ps.setString(1, c.getCode());
            ps.setString(2, c.getFullName());
            ps.setString(3, c.getPhone());
            ps.setString(4, c.getEmail());
            ps.setString(5, c.getAddress());
            ps.setDate(6, c.getBirthDate() == null ? null : Date.valueOf(c.getBirthDate()));
            ps.executeUpdate();
            c.setId(generatedId(ps));
            return true;
        } catch (SQLException e) {
            return false;
        }
    }

    /** Dung cho dat ban / dat mon truc tuyen: tim theo so dien thoai, chua co thi tao moi. */
    public Customer0 getOrCreateCustomer(String fullName, String phone, String email) {
        Customer0 c = getCustomerByPhone(phone);
        if (c != null) return c;
        c = new Customer0();
        c.setFullName(fullName);
        c.setPhone(phone);
        c.setEmail(email == null || email.isBlank() ? null : email);
        return addCustomer(c) ? c : null;
    }
}

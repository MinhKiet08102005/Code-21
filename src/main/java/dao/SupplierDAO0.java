package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Supplier0;

/** Truy xuat nha cung cap. */
public class SupplierDAO0 extends DAO0 {

    public SupplierDAO0() {
        super();
    }

    static Supplier0 map(ResultSet rs) throws SQLException {
        Supplier0 s = new Supplier0();
        s.setId(rs.getInt("id"));
        s.setCode(rs.getString("code"));
        s.setName(rs.getString("name"));
        s.setAddress(rs.getString("address"));
        s.setPhone(rs.getString("phone"));
        s.setEmail(rs.getString("email"));
        s.setDescription(rs.getString("description"));
        return s;
    }

    /** Tim nha cung cap co ten chua tu khoa. Tu khoa rong = tat ca. */
    public List<Supplier0> searchSupplier(String supplierName) {
        List<Supplier0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM tblSupplier0 WHERE LOWER(name) LIKE ? ORDER BY code")) {
            ps.setString(1, "%" + (supplierName == null ? "" : supplierName.trim().toLowerCase()) + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    public Supplier0 getSupplierById(int id) {
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblSupplier0 WHERE id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** Them nha cung cap moi, sinh ma NCCxxx. */
    public boolean addSupplier(Supplier0 supplier) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblSupplier0 (code, name, address, phone, email, description) VALUES (?,?,?,?,?,?)",
                Statement.RETURN_GENERATED_KEYS)) {
            supplier.setCode(nextCode("tblSupplier0", "NCC", 3));
            ps.setString(1, supplier.getCode());
            ps.setString(2, supplier.getName().trim());
            ps.setString(3, supplier.getAddress().trim());
            ps.setString(4, supplier.getPhone().trim());
            ps.setString(5, supplier.getEmail());
            ps.setString(6, supplier.getDescription());
            ps.executeUpdate();
            supplier.setId(generatedId(ps));
            return true;
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean updateSupplier(Supplier0 s) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblSupplier0 SET name=?, address=?, phone=?, email=?, description=? WHERE id=?")) {
            ps.setString(1, s.getName().trim());
            ps.setString(2, s.getAddress().trim());
            ps.setString(3, s.getPhone().trim());
            ps.setString(4, s.getEmail());
            ps.setString(5, s.getDescription());
            ps.setInt(6, s.getId());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            return false;
        }
    }

    /** Chi xoa duoc nha cung cap chua co phieu nhap nao. */
    public boolean deleteSupplier(int id) {
        try {
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM tblImportInvoice0 WHERE idSupplier = ?")) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) > 0) return false;
                }
            }
            try (PreparedStatement ps = con.prepareStatement("DELETE FROM tblSupplier0 WHERE id = ?")) {
                ps.setInt(1, id);
                return ps.executeUpdate() == 1;
            }
        } catch (SQLException e) {
            return false;
        }
    }
}

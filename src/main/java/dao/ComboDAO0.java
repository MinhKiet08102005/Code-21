package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Combo0;
import model.ComboDetail0;
import model.ManagementStaff0;

/** Truy xuat thuc don combo. */
public class ComboDAO0 extends DAO0 {

    public ComboDAO0() {
        super();
    }

    private static Combo0 map(ResultSet rs) throws SQLException {
        Combo0 c = new Combo0();
        c.setId(rs.getInt("id"));
        c.setCode(rs.getString("code"));
        c.setName(rs.getString("name"));
        c.setPrice(rs.getBigDecimal("price"));
        c.setDescription(rs.getString("description"));
        c.setStatus(rs.getString("status"));
        ManagementStaff0 m = new ManagementStaff0();
        m.setId(rs.getInt("idCreatedBy"));
        c.setCreatedBy(m);
        return c;
    }

    private List<Combo0> query(String where, Object... args) {
        List<Combo0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblCombo0 " + where)) {
            for (int i = 0; i < args.length; i++) ps.setObject(i + 1, args[i]);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
            for (Combo0 c : list) c.setDetails(getDetails(c.getId()));
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    private List<ComboDetail0> getDetails(int idCombo) throws SQLException {
        List<ComboDetail0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT cd.id AS cdId, cd.quantity, d.*, c.name AS categoryName, u.fullName AS creatorName "
                        + "FROM tblComboDetail0 cd JOIN tblDish0 d ON d.id = cd.idDish "
                        + "JOIN tblDishCategory0 c ON c.id = d.idCategory JOIN tblUser0 u ON u.id = d.idCreatedBy "
                        + "WHERE cd.idCombo = ? ORDER BY cd.id")) {
            ps.setInt(1, idCombo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ComboDetail0 d = new ComboDetail0();
                    d.setId(rs.getInt("cdId"));
                    d.setQuantity(rs.getInt("quantity"));
                    d.setDish(DishDAO0.map(rs));
                    list.add(d);
                }
            }
        }
        return list;
    }

    public List<Combo0> getComboList() {
        return query("ORDER BY code");
    }

    public Combo0 getComboById(int id) {
        List<Combo0> l = query("WHERE id = ?", id);
        return l.isEmpty() ? null : l.get(0);
    }

    /** Combo dang ban, tim theo ten. Tu khoa rong = tat ca. */
    public List<Combo0> searchCombo(String keyword) {
        String k = "%" + (keyword == null ? "" : keyword.trim().toLowerCase()) + "%";
        return query("WHERE status = ? AND LOWER(name) LIKE ? ORDER BY name", DishDAO0.AVAILABLE, k);
    }

    public boolean checkDuplicateName(String name) {
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM tblCombo0 WHERE LOWER(TRIM(name)) = ?")) {
            ps.setString(1, name.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** Luu combo cung danh sach mon trong mot giao dich. */
    public boolean addCombo(Combo0 combo) {
        synchronized (DAO0.class) {
            try {
                con.setAutoCommit(false);
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblCombo0 (code, name, price, description, status, idCreatedBy) VALUES (?,?,?,?,?,?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    combo.setCode(nextCode("tblCombo0", "CB", 3));
                    ps.setString(1, combo.getCode());
                    ps.setString(2, combo.getName().trim());
                    ps.setBigDecimal(3, combo.getPrice());
                    ps.setString(4, combo.getDescription());
                    ps.setString(5, DishDAO0.AVAILABLE);
                    ps.setInt(6, combo.getCreatedBy().getId());
                    ps.executeUpdate();
                    combo.setId(generatedId(ps));
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblComboDetail0 (quantity, idCombo, idDish) VALUES (?,?,?)")) {
                    for (ComboDetail0 d : combo.getDetails()) {
                        ps.setInt(1, d.getQuantity());
                        ps.setInt(2, combo.getId());
                        ps.setInt(3, d.getDish().getId());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                con.commit();
                return true;
            } catch (SQLException e) {
                rollbackQuietly();
                return false;
            } finally {
                autoCommitQuietly();
            }
        }
    }

    public boolean updateStatus(int id, String status) {
        try (PreparedStatement ps = con.prepareStatement("UPDATE tblCombo0 SET status = ? WHERE id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            return false;
        }
    }
}

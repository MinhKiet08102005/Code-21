package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Dish0;
import model.DishCategory0;
import model.ManagementStaff0;

/** Truy xuat mon an (module Them mon an moi va cac chuc nang lien quan). */
public class DishDAO0 extends DAO0 {

    public static final String AVAILABLE = "Đang bán";
    public static final String STOPPED = "Ngừng bán";

    private static final String SELECT = "SELECT d.*, c.name AS categoryName, u.fullName AS creatorName "
            + "FROM tblDish0 d JOIN tblDishCategory0 c ON c.id = d.idCategory JOIN tblUser0 u ON u.id = d.idCreatedBy ";

    public DishDAO0() {
        super();
    }

    static Dish0 map(ResultSet rs) throws SQLException {
        Dish0 d = new Dish0();
        d.setId(rs.getInt("id"));
        d.setCode(rs.getString("code"));
        d.setName(rs.getString("name"));
        d.setSellingPrice(rs.getBigDecimal("sellingPrice"));
        d.setDescription(rs.getString("description"));
        d.setImagePath(rs.getString("imagePath"));
        d.setStatus(rs.getString("status"));
        DishCategory0 c = new DishCategory0();
        c.setId(rs.getInt("idCategory"));
        c.setName(rs.getString("categoryName"));
        d.setCategory(c);
        ManagementStaff0 m = new ManagementStaff0();
        m.setId(rs.getInt("idCreatedBy"));
        m.setFullName(rs.getString("creatorName"));
        d.setCreatedBy(m);
        return d;
    }

    private List<Dish0> query(String where, Object... args) {
        List<Dish0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(SELECT + where)) {
            for (int i = 0; i < args.length; i++) ps.setObject(i + 1, args[i]);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    /** Danh sach toan bo mon an (giao dien quan li thong tin mon an). */
    public List<Dish0> getDishList() {
        return query("ORDER BY d.code");
    }

    public Dish0 getDishById(int id) {
        List<Dish0> l = query("WHERE d.id = ?", id);
        return l.isEmpty() ? null : l.get(0);
    }

    /** Mon dang ban, tim theo ten (khach hang tim kiem, nhan vien goi mon). Tu khoa rong = tat ca. */
    public List<Dish0> searchDish(String keyword) {
        String k = "%" + (keyword == null ? "" : keyword.trim().toLowerCase()) + "%";
        return query("WHERE d.status = ? AND LOWER(d.name) LIKE ? ORDER BY c.id, d.name", AVAILABLE, k);
    }

    /** Kiem tra ten mon da ton tai trong thuc don chua (khong phan biet hoa thuong). */
    public boolean checkDuplicateName(String dishName) {
        return checkDuplicateName(dishName, 0);
    }

    /** Ban dung khi sua mon: bo qua chinh mon dang sua. */
    public boolean checkDuplicateName(String dishName, int excludeId) {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT COUNT(*) FROM tblDish0 WHERE LOWER(TRIM(name)) = ? AND id <> ?")) {
            ps.setString(1, dishName.trim().toLowerCase());
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** Them mon an moi: sinh ma MAxxx, luu va gan id, ma vao doi tuong. */
    public boolean addDish(Dish0 dish) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblDish0 (code, name, sellingPrice, description, imagePath, status, idCategory, idCreatedBy) "
                        + "VALUES (?,?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS)) {
            dish.setCode(nextCode("tblDish0", "MA", 3));
            ps.setString(1, dish.getCode());
            ps.setString(2, dish.getName().trim());
            ps.setBigDecimal(3, dish.getSellingPrice());
            ps.setString(4, dish.getDescription());
            ps.setString(5, dish.getImagePath());
            ps.setString(6, dish.getStatus() == null ? AVAILABLE : dish.getStatus());
            ps.setInt(7, dish.getCategory().getId());
            ps.setInt(8, dish.getCreatedBy().getId());
            ps.executeUpdate();
            dish.setId(generatedId(ps));
            return true;
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean updateDish(Dish0 dish) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblDish0 SET name=?, sellingPrice=?, description=?, imagePath=?, status=?, idCategory=? WHERE id=?")) {
            ps.setString(1, dish.getName().trim());
            ps.setBigDecimal(2, dish.getSellingPrice());
            ps.setString(3, dish.getDescription());
            ps.setString(4, dish.getImagePath());
            ps.setString(5, dish.getStatus());
            ps.setInt(6, dish.getCategory().getId());
            ps.setInt(7, dish.getId());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            return false;
        }
    }

    /**
     * Xoa mon an. Mon da nam trong don goi mon hoac combo thi khong xoa duoc (de giu lich su),
     * khi do chuyen sang trang thai Ngung ban.
     * @return 1 da xoa, 2 da chuyen sang Ngung ban, 0 that bai
     */
    public int deleteDish(int id) {
        try {
            if (count("SELECT COUNT(*) FROM tblOrderDetail0 WHERE idDish = ?", id) > 0
                    || count("SELECT COUNT(*) FROM tblComboDetail0 WHERE idDish = ?", id) > 0) {
                try (PreparedStatement ps = con.prepareStatement("UPDATE tblDish0 SET status = ? WHERE id = ?")) {
                    ps.setString(1, STOPPED);
                    ps.setInt(2, id);
                    return ps.executeUpdate() == 1 ? 2 : 0;
                }
            }
            try (PreparedStatement ps = con.prepareStatement("DELETE FROM tblDish0 WHERE id = ?")) {
                ps.setInt(1, id);
                return ps.executeUpdate() == 1 ? 1 : 0;
            }
        } catch (SQLException e) {
            return 0;
        }
    }

    private int count(String sql, int id) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }
}

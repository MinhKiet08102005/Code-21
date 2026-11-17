package dao;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Ingredient0;

/** Truy xuat nguyen lieu. */
public class IngredientDAO0 extends DAO0 {

    public IngredientDAO0() {
        super();
    }

    static Ingredient0 map(ResultSet rs) throws SQLException {
        Ingredient0 i = new Ingredient0();
        i.setId(rs.getInt("id"));
        i.setCode(rs.getString("code"));
        i.setName(rs.getString("name"));
        i.setUnit(rs.getString("unit"));
        i.setStockQuantity(rs.getBigDecimal("stockQuantity"));
        i.setDescription(rs.getString("description"));
        return i;
    }

    /** Tim nguyen lieu co ten chua tu khoa. */
    public List<Ingredient0> searchIngredient(String ingredientName) {
        List<Ingredient0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM tblIngredient0 WHERE LOWER(name) LIKE ? ORDER BY code")) {
            ps.setString(1, "%" + (ingredientName == null ? "" : ingredientName.trim().toLowerCase()) + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    public Ingredient0 getIngredientById(int id) {
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblIngredient0 WHERE id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    public boolean checkDuplicateName(String name) {
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM tblIngredient0 WHERE LOWER(TRIM(name)) = ?")) {
            ps.setString(1, name.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** Them nguyen lieu moi (ton kho ban dau 0), sinh ma NLxxx. */
    public boolean addIngredient(Ingredient0 ingredient) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblIngredient0 (code, name, unit, stockQuantity, description) VALUES (?,?,?,?,?)",
                Statement.RETURN_GENERATED_KEYS)) {
            ingredient.setCode(nextCode("tblIngredient0", "NL", 3));
            ingredient.setStockQuantity(BigDecimal.ZERO);
            ps.setString(1, ingredient.getCode());
            ps.setString(2, ingredient.getName().trim());
            ps.setString(3, ingredient.getUnit().trim());
            ps.setBigDecimal(4, BigDecimal.ZERO);
            ps.setString(5, ingredient.getDescription());
            ps.executeUpdate();
            ingredient.setId(generatedId(ps));
            return true;
        } catch (SQLException e) {
            return false;
        }
    }

    /** Cong so luong nhap vao ton kho (goi trong giao dich luu phieu nhap). */
    public boolean updateStock(int idIngredient, BigDecimal quantity) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblIngredient0 SET stockQuantity = stockQuantity + ? WHERE id = ?")) {
            ps.setBigDecimal(1, quantity);
            ps.setInt(2, idIngredient);
            return ps.executeUpdate() == 1;
        }
    }
}

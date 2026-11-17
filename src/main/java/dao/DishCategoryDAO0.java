package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.DishCategory0;

/** Truy xuat danh muc mon an. */
public class DishCategoryDAO0 extends DAO0 {

    public DishCategoryDAO0() {
        super();
    }

    public List<DishCategory0> getCategories() {
        List<DishCategory0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblDishCategory0 ORDER BY id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                DishCategory0 c = new DishCategory0();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setDescription(rs.getString("description"));
                list.add(c);
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    public DishCategory0 getCategoryById(int id) {
        for (DishCategory0 c : getCategories()) if (c.getId() == id) return c;
        return null;
    }
}

package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.DiningTable0;

/** Truy xuat ban an. */
public class DiningTableDAO0 extends DAO0 {

    public static final String FREE = "Trống";
    public static final String OCCUPIED = "Có khách";

    public DiningTableDAO0() {
        super();
    }

    static DiningTable0 map(ResultSet rs) throws SQLException {
        DiningTable0 t = new DiningTable0();
        t.setId(rs.getInt("id"));
        t.setCode(rs.getString("code"));
        t.setTableNumber(rs.getInt("tableNumber"));
        t.setCapacity(rs.getInt("capacity"));
        t.setLocation(rs.getString("location"));
        t.setStatus(rs.getString("status"));
        return t;
    }

    private List<DiningTable0> query(String where, Object... args) {
        List<DiningTable0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement("SELECT * FROM tblDiningTable0 " + where)) {
            for (int i = 0; i < args.length; i++) ps.setObject(i + 1, args[i]);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    public List<DiningTable0> getTables() {
        return query("ORDER BY tableNumber");
    }

    public DiningTable0 getTableById(int id) {
        List<DiningTable0> l = query("WHERE id = ?", id);
        return l.isEmpty() ? null : l.get(0);
    }

    /** Ban dang trong co suc chua tu so khach tro len, ban nho truoc. */
    public List<DiningTable0> getAvailableTables(int numberOfGuests) {
        return query("WHERE status = ? AND capacity >= ? ORDER BY capacity, tableNumber", FREE, numberOfGuests);
    }

    public List<DiningTable0> getOccupiedTables() {
        return query("WHERE status = ? ORDER BY tableNumber", OCCUPIED);
    }

    public boolean updateStatus(int idTable, String status) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("UPDATE tblDiningTable0 SET status = ? WHERE id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, idTable);
            return ps.executeUpdate() == 1;
        }
    }
}

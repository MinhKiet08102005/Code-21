package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import model.DiningTable0;
import model.SaleStaff0;
import model.TableReservation0;

/** Truy xuat phieu dat ban truc tuyen. */
public class TableReservationDAO0 extends DAO0 {

    public static final String PENDING = "Chờ xác nhận";
    public static final String CONFIRMED = "Đã xác nhận";
    public static final String REJECTED = "Bị từ chối";
    public static final String ARRIVED = "Đã nhận bàn";

    private static final String SELECT = "SELECT r.id AS rId, r.code AS rCode, r.reservationTime, r.numberOfGuests, r.note, "
            + "r.status AS rStatus, r.createdAt, r.idTable, r.idSaleStaff, t.code AS tCode, t.tableNumber, t.capacity, "
            + "t.location, u.fullName AS staffName, c.* FROM tblTableReservation0 r "
            + "JOIN tblCustomer0 c ON c.id = r.idCustomer LEFT JOIN tblDiningTable0 t ON t.id = r.idTable "
            + "LEFT JOIN tblUser0 u ON u.id = r.idSaleStaff ";

    public TableReservationDAO0() {
        super();
    }

    private static TableReservation0 map(ResultSet rs) throws SQLException {
        TableReservation0 r = new TableReservation0();
        r.setId(rs.getInt("rId"));
        r.setCode(rs.getString("rCode"));
        r.setReservationTime(toLdt(rs.getTimestamp("reservationTime")));
        r.setNumberOfGuests(rs.getInt("numberOfGuests"));
        r.setNote(rs.getString("note"));
        r.setStatus(rs.getString("rStatus"));
        r.setCreatedAt(toLdt(rs.getTimestamp("createdAt")));
        r.setCustomer(CustomerDAO0.map(rs));
        if (rs.getObject("idTable") != null) {
            DiningTable0 t = new DiningTable0();
            t.setId(rs.getInt("idTable"));
            t.setCode(rs.getString("tCode"));
            t.setTableNumber(rs.getInt("tableNumber"));
            t.setCapacity(rs.getInt("capacity"));
            t.setLocation(rs.getString("location"));
            r.setTable(t);
        }
        if (rs.getObject("idSaleStaff") != null) {
            SaleStaff0 s = new SaleStaff0();
            s.setId(rs.getInt("idSaleStaff"));
            s.setFullName(rs.getString("staffName"));
            r.setSaleStaff(s);
        }
        return r;
    }

    private List<TableReservation0> query(String where, Object... args) {
        List<TableReservation0> list = new ArrayList<>();
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

    /** Khach hang dat ban: trang thai Cho xac nhan, sinh ma DBxxxx. */
    public boolean addReservation(TableReservation0 r) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblTableReservation0 (code, reservationTime, numberOfGuests, note, status, createdAt, idCustomer) "
                        + "VALUES (?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS)) {
            r.setCode(nextCode("tblTableReservation0", "DB", 4));
            r.setStatus(PENDING);
            r.setCreatedAt(LocalDateTime.now().withNano(0));
            ps.setString(1, r.getCode());
            ps.setTimestamp(2, toTs(r.getReservationTime()));
            ps.setInt(3, r.getNumberOfGuests());
            ps.setString(4, r.getNote());
            ps.setString(5, r.getStatus());
            ps.setTimestamp(6, toTs(r.getCreatedAt()));
            ps.setInt(7, r.getCustomer().getId());
            ps.executeUpdate();
            r.setId(generatedId(ps));
            return true;
        } catch (SQLException e) {
            return false;
        }
    }

    public List<TableReservation0> getReservationsByStatus(String status) {
        return query("WHERE r.status = ? ORDER BY r.reservationTime", status);
    }

    public List<TableReservation0> getReservationsByPhone(String phone) {
        return query("WHERE c.phone = ? ORDER BY r.reservationTime DESC", phone);
    }

    public TableReservation0 getReservationById(int id) {
        List<TableReservation0> l = query("WHERE r.id = ?", id);
        return l.isEmpty() ? null : l.get(0);
    }

    /** Nhan vien ban hang xac nhan va xep ban cho phieu dat ban. */
    public boolean confirmReservation(int id, int idTable, int idSaleStaff) {
        return update("UPDATE tblTableReservation0 SET status = ?, idTable = ?, idSaleStaff = ? WHERE id = ? AND status = ?",
                CONFIRMED, idTable, idSaleStaff, id, PENDING);
    }

    public boolean rejectReservation(int id, int idSaleStaff) {
        return update("UPDATE tblTableReservation0 SET status = ?, idSaleStaff = ? WHERE id = ? AND status = ?",
                REJECTED, idSaleStaff, id, PENDING);
    }

    /** Khach den nhan ban (goi trong giao dich mo don goi mon). */
    public boolean markArrived(int id, int idTable) {
        return update("UPDATE tblTableReservation0 SET status = ?, idTable = ? WHERE id = ?", ARRIVED, idTable, id);
    }

    private boolean update(String sql, Object... args) {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < args.length; i++) ps.setObject(i + 1, args[i]);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            return false;
        }
    }
}

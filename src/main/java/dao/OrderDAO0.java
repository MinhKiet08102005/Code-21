package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import model.Customer0;
import model.DiningTable0;
import model.Order0;
import model.OrderDetail0;
import model.SaleStaff0;

/** Truy xuat don goi mon: tai ban va truc tuyen. */
public class OrderDAO0 extends DAO0 {

    public static final String AT_TABLE = "Tại bàn";
    public static final String ONLINE = "Trực tuyến";
    public static final String SERVING = "Đang phục vụ";
    public static final String PAID = "Đã thanh toán";
    public static final String PENDING = "Chờ xác nhận";
    public static final String CONFIRMED = "Đã xác nhận";
    public static final String REJECTED = "Bị từ chối";

    private static final String SELECT = "SELECT o.id AS oId, o.code AS oCode, o.orderTime, o.status AS oStatus, o.orderType, "
            + "o.note, o.idTable, o.idSaleStaff, o.idCustomer, t.code AS tCode, t.tableNumber, t.capacity, t.location, "
            + "t.status AS tStatus, u.fullName AS staffName, c.* FROM tblOrder0 o "
            + "LEFT JOIN tblDiningTable0 t ON t.id = o.idTable LEFT JOIN tblUser0 u ON u.id = o.idSaleStaff "
            + "LEFT JOIN tblCustomer0 c ON c.id = o.idCustomer ";

    public OrderDAO0() {
        super();
    }

    private static Order0 map(ResultSet rs) throws SQLException {
        Order0 o = new Order0();
        o.setId(rs.getInt("oId"));
        o.setCode(rs.getString("oCode"));
        o.setOrderTime(toLdt(rs.getTimestamp("orderTime")));
        o.setStatus(rs.getString("oStatus"));
        o.setOrderType(rs.getString("orderType"));
        o.setNote(rs.getString("note"));
        if (rs.getObject("idTable") != null) {
            DiningTable0 t = new DiningTable0();
            t.setId(rs.getInt("idTable"));
            t.setCode(rs.getString("tCode"));
            t.setTableNumber(rs.getInt("tableNumber"));
            t.setCapacity(rs.getInt("capacity"));
            t.setLocation(rs.getString("location"));
            t.setStatus(rs.getString("tStatus"));
            o.setTable(t);
        }
        if (rs.getObject("idSaleStaff") != null) {
            SaleStaff0 s = new SaleStaff0();
            s.setId(rs.getInt("idSaleStaff"));
            s.setFullName(rs.getString("staffName"));
            o.setSaleStaff(s);
        }
        if (rs.getObject("idCustomer") != null) o.setCustomer(CustomerDAO0.map(rs));
        return o;
    }

    private List<Order0> query(String where, Object... args) {
        List<Order0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(SELECT + where)) {
            for (int i = 0; i < args.length; i++) ps.setObject(i + 1, args[i]);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        OrderDetailDAO0 dd = new OrderDetailDAO0();
        for (Order0 o : list) o.setDetails(dd.getDetailsByOrder(o.getId()));
        return list;
    }

    public Order0 getOrderById(int id) {
        List<Order0> l = query("WHERE o.id = ?", id);
        return l.isEmpty() ? null : l.get(0);
    }

    /** Don dang phuc vu cua mot ban (moi ban toi da mot don dang phuc vu). */
    public Order0 getActiveOrderByTable(int idTable) {
        List<Order0> l = query("WHERE o.idTable = ? AND o.status = ?", idTable, SERVING);
        return l.isEmpty() ? null : l.get(0);
    }

    public List<Order0> getServingOrders() {
        return query("WHERE o.status = ? ORDER BY t.tableNumber", SERVING);
    }

    public List<Order0> getPendingOnlineOrders() {
        return query("WHERE o.orderType = ? AND o.status = ? ORDER BY o.orderTime", ONLINE, PENDING);
    }

    /** Don cho thanh toan: don tai ban dang phuc vu va don truc tuyen da xac nhan. */
    public List<Order0> getOrdersAwaitingPayment() {
        return query("WHERE o.status = ? OR (o.orderType = ? AND o.status = ?) ORDER BY o.orderTime",
                SERVING, ONLINE, CONFIRMED);
    }

    public List<Order0> getOrdersByPhone(String phone) {
        return query("WHERE c.phone = ? ORDER BY o.orderTime DESC", phone);
    }

    /**
     * Tiep nhan khach: mo don goi mon cho ban va chuyen ban sang Co khach (mot giao dich).
     * idReservation &gt; 0 khi khach den theo phieu dat ban.
     */
    public Order0 openTableOrder(int idTable, int idSaleStaff, Customer0 customer, int idReservation) {
        synchronized (DAO0.class) {
            DiningTableDAO0 tableDAO = new DiningTableDAO0();
            try {
                DiningTable0 t = tableDAO.getTableById(idTable);
                if (t == null || !DiningTableDAO0.FREE.equals(t.getStatus())) return null;
                con.setAutoCommit(false);
                Order0 o = new Order0();
                o.setCode(nextCode("tblOrder0", "DG", 4));
                o.setOrderTime(LocalDateTime.now().withNano(0));
                o.setStatus(SERVING);
                o.setOrderType(AT_TABLE);
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblOrder0 (code, orderTime, status, orderType, idTable, idSaleStaff, idCustomer) VALUES (?,?,?,?,?,?,?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, o.getCode());
                    ps.setTimestamp(2, toTs(o.getOrderTime()));
                    ps.setString(3, o.getStatus());
                    ps.setString(4, o.getOrderType());
                    ps.setInt(5, idTable);
                    ps.setInt(6, idSaleStaff);
                    ps.setObject(7, customer == null ? null : customer.getId());
                    ps.executeUpdate();
                    o.setId(generatedId(ps));
                }
                tableDAO.updateStatus(idTable, DiningTableDAO0.OCCUPIED);
                if (idReservation > 0 && !new TableReservationDAO0().markArrived(idReservation, idTable)) {
                    throw new SQLException("Không cập nhật được phiếu đặt bàn");
                }
                con.commit();
                return o;
            } catch (SQLException e) {
                rollbackQuietly();
                return null;
            } finally {
                autoCommitQuietly();
            }
        }
    }

    /** Khach hang dat mon truc tuyen: luu don (Cho xac nhan) va cac mon trong mot giao dich. */
    public boolean addOnlineOrder(Order0 order) {
        synchronized (DAO0.class) {
            OrderDetailDAO0 dd = new OrderDetailDAO0();
            try {
                con.setAutoCommit(false);
                order.setCode(nextCode("tblOrder0", "DG", 4));
                order.setOrderTime(LocalDateTime.now().withNano(0));
                order.setStatus(PENDING);
                order.setOrderType(ONLINE);
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblOrder0 (code, orderTime, status, orderType, note, idCustomer) VALUES (?,?,?,?,?,?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, order.getCode());
                    ps.setTimestamp(2, toTs(order.getOrderTime()));
                    ps.setString(3, order.getStatus());
                    ps.setString(4, order.getOrderType());
                    ps.setString(5, order.getNote());
                    ps.setInt(6, order.getCustomer().getId());
                    ps.executeUpdate();
                    order.setId(generatedId(ps));
                }
                for (OrderDetail0 d : order.getDetails()) {
                    d.setOrderId(order.getId());
                    if (!dd.addDetail(d)) throw new SQLException("Không lưu được món");
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

    public boolean confirmOnlineOrder(int id, int idSaleStaff) {
        return setStatus(id, CONFIRMED, idSaleStaff, PENDING);
    }

    public boolean rejectOnlineOrder(int id, int idSaleStaff) {
        return setStatus(id, REJECTED, idSaleStaff, PENDING);
    }

    private boolean setStatus(int id, String status, int idSaleStaff, String expected) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblOrder0 SET status = ?, idSaleStaff = ? WHERE id = ? AND status = ?")) {
            ps.setString(1, status);
            ps.setInt(2, idSaleStaff);
            ps.setInt(3, id);
            ps.setString(4, expected);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            return false;
        }
    }
}

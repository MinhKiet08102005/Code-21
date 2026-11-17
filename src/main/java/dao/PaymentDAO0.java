package dao;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDateTime;

import model.Customer0;
import model.MembershipCard0;
import model.Order0;
import model.Payment0;
import model.SaleStaff0;

/** Thanh toan tai ban. */
public class PaymentDAO0 extends DAO0 {

    /** Moi 10.000 d so tien thuc tra duoc 1 diem. */
    public static final BigDecimal POINT_UNIT = new BigDecimal("10000");

    public PaymentDAO0() {
        super();
    }

    /**
     * Luu hoa don, chuyen don sang Da thanh toan, tra ban ve Trong va cong diem the (mot giao dich).
     * Tra ve false neu don khong ton tai, khong co mon, hoac da thanh toan roi.
     */
    public boolean savePayment(Payment0 p) {
        synchronized (DAO0.class) {
            try {
                Order0 order = new OrderDAO0().getOrderById(p.getOrder().getId());
                if (order == null || order.getDetails().isEmpty() || OrderDAO0.PAID.equals(order.getStatus())) return false;
                con.setAutoCommit(false);
                p.setOrder(order);
                p.setTotalAmount(order.getTotalAmount());
                if (p.getDiscount() == null) p.setDiscount(BigDecimal.ZERO);
                p.setPaymentTime(LocalDateTime.now().withNano(0));
                p.setCode(nextCode("tblPayment0", "HD", 4));
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblPayment0 (code, paymentTime, totalAmount, discount, paymentMethod, idOrder, idSaleStaff, idCustomer) "
                                + "VALUES (?,?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, p.getCode());
                    ps.setTimestamp(2, toTs(p.getPaymentTime()));
                    ps.setBigDecimal(3, p.getTotalAmount());
                    ps.setBigDecimal(4, p.getDiscount());
                    ps.setString(5, p.getPaymentMethod());
                    ps.setInt(6, order.getId());
                    ps.setInt(7, p.getSaleStaff().getId());
                    ps.setObject(8, p.getCustomer() == null ? null : p.getCustomer().getId());
                    ps.executeUpdate();
                    p.setId(generatedId(ps));
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE tblOrder0 SET status = ?, idCustomer = COALESCE(?, idCustomer), idSaleStaff = COALESCE(idSaleStaff, ?) WHERE id = ?")) {
                    ps.setString(1, OrderDAO0.PAID);
                    ps.setObject(2, p.getCustomer() == null ? null : p.getCustomer().getId());
                    ps.setInt(3, p.getSaleStaff().getId());
                    ps.setInt(4, order.getId());
                    ps.executeUpdate();
                }
                if (order.getTable() != null) new DiningTableDAO0().updateStatus(order.getTable().getId(), DiningTableDAO0.FREE);
                if (p.getCustomer() != null) {
                    MembershipCard0 card = new MembershipCardDAO0().getCardByCustomer(p.getCustomer().getId());
                    if (card != null) {
                        int points = p.getFinalAmount().divideToIntegralValue(POINT_UNIT).intValue();
                        new MembershipCardDAO0().addPoints(card.getId(), points);
                    }
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

    public Payment0 getPaymentById(int id) {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT p.*, u.fullName AS staffName FROM tblPayment0 p JOIN tblUser0 u ON u.id = p.idSaleStaff WHERE p.id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Payment0 p = new Payment0();
                p.setId(rs.getInt("id"));
                p.setCode(rs.getString("code"));
                p.setPaymentTime(toLdt(rs.getTimestamp("paymentTime")));
                p.setTotalAmount(rs.getBigDecimal("totalAmount"));
                p.setDiscount(rs.getBigDecimal("discount"));
                p.setPaymentMethod(rs.getString("paymentMethod"));
                SaleStaff0 s = new SaleStaff0();
                s.setId(rs.getInt("idSaleStaff"));
                s.setFullName(rs.getString("staffName"));
                p.setSaleStaff(s);
                int idOrder = rs.getInt("idOrder");
                Object idCustomer = rs.getObject("idCustomer");
                rs.close();
                p.setOrder(new OrderDAO0().getOrderById(idOrder));
                if (idCustomer != null) {
                    Customer0 c = new CustomerDAO0().getCustomerById(((Number) idCustomer).intValue());
                    p.setCustomer(c);
                }
                return p;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }
}

package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Combo0;
import model.Dish0;
import model.OrderDetail0;

/** Truy xuat chi tiet don goi mon. */
public class OrderDetailDAO0 extends DAO0 {

    public OrderDetailDAO0() {
        super();
    }

    /**
     * Them mot mon / combo vao don. Neu don da co dung mon do thi cong don so luong.
     */
    public boolean addDetail(OrderDetail0 detail) throws SQLException {
        String col = detail.getDish() != null ? "idDish" : "idCombo";
        int itemId = detail.getDish() != null ? detail.getDish().getId() : detail.getCombo().getId();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT id, quantity FROM tblOrderDetail0 WHERE idOrder = ? AND " + col + " = ?")) {
            ps.setInt(1, detail.getOrderId());
            ps.setInt(2, itemId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return updateQuantity(rs.getInt("id"), rs.getInt("quantity") + detail.getQuantity());
            }
        }
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblOrderDetail0 (quantity, unitPrice, amount, idOrder, idDish, idCombo) VALUES (?,?,?,?,?,?)")) {
            ps.setInt(1, detail.getQuantity());
            ps.setBigDecimal(2, detail.getUnitPrice());
            ps.setBigDecimal(3, detail.calculateAmount());
            ps.setInt(4, detail.getOrderId());
            ps.setObject(5, detail.getDish() != null ? detail.getDish().getId() : null);
            ps.setObject(6, detail.getCombo() != null ? detail.getCombo().getId() : null);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateQuantity(int idDetail, int quantity) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE tblOrderDetail0 SET quantity = ?, amount = unitPrice * ? WHERE id = ?")) {
            ps.setInt(1, quantity);
            ps.setInt(2, quantity);
            ps.setInt(3, idDetail);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean deleteDetail(int idDetail) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM tblOrderDetail0 WHERE id = ?")) {
            ps.setInt(1, idDetail);
            return ps.executeUpdate() == 1;
        }
    }

    public List<OrderDetail0> getDetailsByOrder(int idOrder) {
        List<OrderDetail0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT od.*, d.code AS dCode, d.name AS dName, c.code AS cCode, c.name AS cName "
                        + "FROM tblOrderDetail0 od LEFT JOIN tblDish0 d ON d.id = od.idDish "
                        + "LEFT JOIN tblCombo0 c ON c.id = od.idCombo WHERE od.idOrder = ? ORDER BY od.id")) {
            ps.setInt(1, idOrder);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderDetail0 d = new OrderDetail0();
                    d.setId(rs.getInt("id"));
                    d.setOrderId(idOrder);
                    d.setQuantity(rs.getInt("quantity"));
                    d.setUnitPrice(rs.getBigDecimal("unitPrice"));
                    d.setAmount(rs.getBigDecimal("amount"));
                    if (rs.getObject("idDish") != null) {
                        Dish0 dish = new Dish0();
                        dish.setId(rs.getInt("idDish"));
                        dish.setCode(rs.getString("dCode"));
                        dish.setName(rs.getString("dName"));
                        d.setDish(dish);
                    } else {
                        Combo0 combo = new Combo0();
                        combo.setId(rs.getInt("idCombo"));
                        combo.setCode(rs.getString("cCode"));
                        combo.setName(rs.getString("cName"));
                        d.setCombo(combo);
                    }
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }
}

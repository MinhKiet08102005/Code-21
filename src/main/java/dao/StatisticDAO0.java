package dao;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import model.CustomerStat0;
import model.DishStat0;
import model.IngredientStat0;
import model.SupplierStat0;

/**
 * Thong ke cho nhan vien quan li. Khoang thoi gian [from, to] tinh ca ngay cuoi.
 * Doanh thu tinh theo hoa don thanh toan; gia tri nhap tinh theo phieu nhap.
 */
public class StatisticDAO0 extends DAO0 {

    public StatisticDAO0() {
        super();
    }

    private static java.sql.Timestamp start(LocalDate d) {
        return java.sql.Timestamp.valueOf(d.atStartOfDay());
    }

    private static java.sql.Timestamp end(LocalDate d) {
        return java.sql.Timestamp.valueOf(d.plusDays(1).atStartOfDay());
    }

    /** Tong doanh thu (sau giam gia) va so hoa don trong ky: {doanhThu, soHoaDon}. */
    public BigDecimal[] getRevenueSummary(LocalDate from, LocalDate to) {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT COALESCE(SUM(totalAmount - discount),0), COUNT(*) FROM tblPayment0 WHERE paymentTime >= ? AND paymentTime < ?")) {
            ps.setTimestamp(1, start(from));
            ps.setTimestamp(2, end(to));
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return new BigDecimal[]{rs.getBigDecimal(1), BigDecimal.valueOf(rs.getInt(2))};
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** Thong ke mon an goi le: so luong ban va doanh thu, giam dan theo doanh thu. */
    public List<DishStat0> getDishStatistic(LocalDate from, LocalDate to) {
        List<DishStat0> list = new ArrayList<>();
        String sql = "SELECT d.id, d.code, d.name, d.sellingPrice, c.name AS categoryName, "
                + "SUM(od.quantity) AS qty, SUM(od.amount) AS revenue FROM tblOrderDetail0 od "
                + "JOIN tblDish0 d ON d.id = od.idDish JOIN tblDishCategory0 c ON c.id = d.idCategory "
                + "JOIN tblPayment0 p ON p.idOrder = od.idOrder "
                + "WHERE p.paymentTime >= ? AND p.paymentTime < ? "
                + "GROUP BY d.id, d.code, d.name, d.sellingPrice, c.name ORDER BY revenue DESC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setTimestamp(1, start(from));
            ps.setTimestamp(2, end(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DishStat0 s = new DishStat0();
                    s.setId(rs.getInt("id"));
                    s.setCode(rs.getString("code"));
                    s.setName(rs.getString("name"));
                    s.setSellingPrice(rs.getBigDecimal("sellingPrice"));
                    model.DishCategory0 cat = new model.DishCategory0();
                    cat.setName(rs.getString("categoryName"));
                    s.setCategory(cat);
                    s.setQuantitySold(rs.getInt("qty"));
                    s.setRevenue(rs.getBigDecimal("revenue"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    /** Thong ke nguyen lieu: so phieu, so luong, gia tri nhap trong ky va ton kho hien tai. */
    public List<IngredientStat0> getIngredientStatistic(LocalDate from, LocalDate to) {
        List<IngredientStat0> list = new ArrayList<>();
        String sql = "SELECT i.id, i.code, i.name, i.unit, i.stockQuantity, "
                + "COUNT(x.idImportInvoice) AS cnt, COALESCE(SUM(x.quantity),0) AS qty, COALESCE(SUM(x.amount),0) AS val "
                + "FROM tblIngredient0 i LEFT JOIN (SELECT d.* FROM tblImportDetail0 d JOIN tblImportInvoice0 ii "
                + "ON ii.id = d.idImportInvoice WHERE ii.importDate >= ? AND ii.importDate < ?) x ON x.idIngredient = i.id "
                + "GROUP BY i.id, i.code, i.name, i.unit, i.stockQuantity ORDER BY val DESC, i.code";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setTimestamp(1, start(from));
            ps.setTimestamp(2, end(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    IngredientStat0 s = new IngredientStat0();
                    s.setId(rs.getInt("id"));
                    s.setCode(rs.getString("code"));
                    s.setName(rs.getString("name"));
                    s.setUnit(rs.getString("unit"));
                    s.setStockQuantity(rs.getBigDecimal("stockQuantity"));
                    s.setInvoiceCount(rs.getInt("cnt"));
                    s.setImportQuantity(rs.getBigDecimal("qty"));
                    s.setImportValue(rs.getBigDecimal("val"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    /** Thong ke khach hang: so lan thanh toan va tong so tien da tra, giam dan. */
    public List<CustomerStat0> getCustomerStatistic(LocalDate from, LocalDate to) {
        List<CustomerStat0> list = new ArrayList<>();
        String sql = "SELECT c.*, COUNT(p.id) AS cnt, SUM(p.totalAmount - p.discount) AS spent FROM tblPayment0 p "
                + "JOIN tblCustomer0 c ON c.id = p.idCustomer WHERE p.paymentTime >= ? AND p.paymentTime < ? "
                + "GROUP BY c.id, c.code, c.fullName, c.phone, c.email, c.address, c.birthDate ORDER BY spent DESC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setTimestamp(1, start(from));
            ps.setTimestamp(2, end(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerStat0 s = new CustomerStat0();
                    s.setId(rs.getInt("id"));
                    s.setCode(rs.getString("code"));
                    s.setFullName(rs.getString("fullName"));
                    s.setPhone(rs.getString("phone"));
                    s.setVisitCount(rs.getInt("cnt"));
                    s.setTotalSpent(rs.getBigDecimal("spent"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    /** Thong ke nha cung cap: so phieu nhap va tong gia tri nhap trong ky, giam dan. */
    public List<SupplierStat0> getSupplierStatistic(LocalDate from, LocalDate to) {
        List<SupplierStat0> list = new ArrayList<>();
        String sql = "SELECT s.*, COUNT(ii.id) AS cnt, COALESCE(SUM(ii.totalAmount),0) AS total FROM tblSupplier0 s "
                + "LEFT JOIN tblImportInvoice0 ii ON ii.idSupplier = s.id AND ii.importDate >= ? AND ii.importDate < ? "
                + "GROUP BY s.id, s.code, s.name, s.address, s.phone, s.email, s.description ORDER BY total DESC, s.code";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setTimestamp(1, start(from));
            ps.setTimestamp(2, end(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SupplierStat0 s = new SupplierStat0();
                    s.setId(rs.getInt("id"));
                    s.setCode(rs.getString("code"));
                    s.setName(rs.getString("name"));
                    s.setPhone(rs.getString("phone"));
                    s.setInvoiceCount(rs.getInt("cnt"));
                    s.setTotalImport(rs.getBigDecimal("total"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }
}

package dao;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import model.ImportDetail0;
import model.ImportInvoice0;
import model.WarehouseStaff0;

/** Truy xuat phieu nhap nguyen lieu. */
public class ImportInvoiceDAO0 extends DAO0 {

    private static final String SELECT = "SELECT ii.id AS invId, ii.code AS invCode, ii.importDate, ii.totalAmount, "
            + "ii.idWarehouseStaff, u.fullName AS staffName, s.* FROM tblImportInvoice0 ii "
            + "JOIN tblSupplier0 s ON s.id = ii.idSupplier JOIN tblUser0 u ON u.id = ii.idWarehouseStaff ";

    public ImportInvoiceDAO0() {
        super();
    }

    private static ImportInvoice0 map(ResultSet rs) throws SQLException {
        ImportInvoice0 inv = new ImportInvoice0();
        inv.setId(rs.getInt("invId"));
        inv.setCode(rs.getString("invCode"));
        inv.setImportDate(toLdt(rs.getTimestamp("importDate")));
        inv.setTotalAmount(rs.getBigDecimal("totalAmount"));
        inv.setSupplier(SupplierDAO0.map(rs));
        WarehouseStaff0 w = new WarehouseStaff0();
        w.setId(rs.getInt("idWarehouseStaff"));
        w.setFullName(rs.getString("staffName"));
        inv.setWarehouseStaff(w);
        return inv;
    }

    /** Tong tien = tong thanh tien cac dong. */
    public BigDecimal calculateTotal(List<ImportDetail0> listDetail) {
        BigDecimal total = BigDecimal.ZERO;
        for (ImportDetail0 d : listDetail) total = total.add(d.calculateAmount());
        return total;
    }

    /**
     * Luu phieu nhap, cac dong chi tiet va cong ton kho trong CUNG MOT giao dich.
     * Loi bat ky buoc nao thi huy toan bo: khong luu phieu, khong cap nhat ton kho.
     */
    public boolean saveImportInvoice(ImportInvoice0 invoice) {
        synchronized (DAO0.class) {
            ImportDetailDAO0 detailDAO = new ImportDetailDAO0();
            IngredientDAO0 ingredientDAO = new IngredientDAO0();
            try {
                con.setAutoCommit(false);
                invoice.setTotalAmount(calculateTotal(invoice.getDetails()));
                if (invoice.getImportDate() == null) invoice.setImportDate(LocalDateTime.now().withNano(0));
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblImportInvoice0 (code, importDate, totalAmount, idSupplier, idWarehouseStaff) VALUES (?,?,?,?,?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    invoice.setCode(nextCode("tblImportInvoice0", "PN", 4));
                    ps.setString(1, invoice.getCode());
                    ps.setTimestamp(2, toTs(invoice.getImportDate()));
                    ps.setBigDecimal(3, invoice.getTotalAmount());
                    ps.setInt(4, invoice.getSupplier().getId());
                    ps.setInt(5, invoice.getWarehouseStaff().getId());
                    ps.executeUpdate();
                    invoice.setId(generatedId(ps));
                }
                for (ImportDetail0 d : invoice.getDetails()) {
                    d.setImportInvoice(invoice);
                    if (!detailDAO.addDetail(d) || !ingredientDAO.updateStock(d.getIngredient().getId(), d.getQuantity())) {
                        throw new SQLException("Không ghi được chi tiết phiếu nhập");
                    }
                }
                con.commit();
                return true;
            } catch (SQLException e) {
                rollbackQuietly();
                invoice.setId(0);
                invoice.setCode(null);
                return false;
            } finally {
                autoCommitQuietly();
            }
        }
    }

    /**
     * In phieu nhap: kiem tra phieu da duoc luu. Viec in thuc te do trinh duyet thuc hien
     * tren trang PrintImportInvoiceView0.jsp; in loi thi in lai cung phieu nay.
     */
    public boolean printInvoice(int idInvoice) {
        return getInvoiceById(idInvoice) != null;
    }

    public ImportInvoice0 getInvoiceById(int id) {
        try (PreparedStatement ps = con.prepareStatement(SELECT + "WHERE ii.id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                ImportInvoice0 inv = map(rs);
                inv.setDetails(new ImportDetailDAO0().getDetailByInvoice(id));
                return inv;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    /** Danh sach phieu nhap moi nhat truoc; idSupplier = 0 la tat ca; from/to co the null. */
    public List<ImportInvoice0> getInvoiceList(int idSupplier, LocalDateTime from, LocalDateTime to) {
        List<ImportInvoice0> list = new ArrayList<>();
        StringBuilder where = new StringBuilder("WHERE 1=1 ");
        if (idSupplier > 0) where.append("AND ii.idSupplier = ? ");
        if (from != null) where.append("AND ii.importDate >= ? ");
        if (to != null) where.append("AND ii.importDate < ? ");
        try (PreparedStatement ps = con.prepareStatement(SELECT + where + "ORDER BY ii.importDate DESC")) {
            int i = 1;
            if (idSupplier > 0) ps.setInt(i++, idSupplier);
            if (from != null) ps.setTimestamp(i++, toTs(from));
            if (to != null) ps.setTimestamp(i, toTs(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }
}

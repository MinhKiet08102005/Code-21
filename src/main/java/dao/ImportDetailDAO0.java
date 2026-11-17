package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.ImportDetail0;

/** Truy xuat chi tiet phieu nhap. */
public class ImportDetailDAO0 extends DAO0 {

    public ImportDetailDAO0() {
        super();
    }

    /** Ghi mot dong chi tiet (goi trong giao dich luu phieu nhap). */
    public boolean addDetail(ImportDetail0 detail) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblImportDetail0 (quantity, unitPrice, amount, idImportInvoice, idIngredient) VALUES (?,?,?,?,?)")) {
            ps.setBigDecimal(1, detail.getQuantity());
            ps.setBigDecimal(2, detail.getUnitPrice());
            ps.setBigDecimal(3, detail.calculateAmount());
            ps.setInt(4, detail.getImportInvoice().getId());
            ps.setInt(5, detail.getIngredient().getId());
            return ps.executeUpdate() == 1;
        }
    }

    public List<ImportDetail0> getDetailByInvoice(int idInvoice) {
        List<ImportDetail0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT d.id AS dId, d.quantity, d.unitPrice, d.amount, i.* FROM tblImportDetail0 d "
                        + "JOIN tblIngredient0 i ON i.id = d.idIngredient WHERE d.idImportInvoice = ? ORDER BY d.id")) {
            ps.setInt(1, idInvoice);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImportDetail0 d = new ImportDetail0();
                    d.setId(rs.getInt("dId"));
                    d.setQuantity(rs.getBigDecimal("quantity"));
                    d.setUnitPrice(rs.getBigDecimal("unitPrice"));
                    d.setAmount(rs.getBigDecimal("amount"));
                    d.setIngredient(IngredientDAO0.map(rs));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }
}

package dao;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.MembershipCard0;
import model.SaleStaff0;

/** Truy xuat the thanh vien. */
public class MembershipCardDAO0 extends DAO0 {

    private static final String SELECT = "SELECT mc.id AS cardId, mc.code AS cardCode, mc.issueDate, mc.tier, mc.points, "
            + "mc.idSaleStaff, u.fullName AS staffName, c.* FROM tblMembershipCard0 mc "
            + "JOIN tblCustomer0 c ON c.id = mc.idCustomer JOIN tblUser0 u ON u.id = mc.idSaleStaff ";

    public MembershipCardDAO0() {
        super();
    }

    private static MembershipCard0 map(ResultSet rs) throws SQLException {
        MembershipCard0 m = new MembershipCard0();
        m.setId(rs.getInt("cardId"));
        m.setCode(rs.getString("cardCode"));
        m.setIssueDate(rs.getDate("issueDate").toLocalDate());
        m.setTier(rs.getString("tier"));
        m.setPoints(rs.getInt("points"));
        m.setCustomer(CustomerDAO0.map(rs));
        SaleStaff0 s = new SaleStaff0();
        s.setId(rs.getInt("idSaleStaff"));
        s.setFullName(rs.getString("staffName"));
        m.setIssuedBy(s);
        return m;
    }

    public MembershipCard0 getCardByCustomer(int idCustomer) {
        try (PreparedStatement ps = con.prepareStatement(SELECT + "WHERE mc.idCustomer = ?")) {
            ps.setInt(1, idCustomer);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    public List<MembershipCard0> getCardList() {
        List<MembershipCard0> list = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(SELECT + "ORDER BY mc.code DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
        return list;
    }

    /** Lap the moi (hang Bac, 0 diem), gan id va ma TVxxxx. */
    public boolean addCard(MembershipCard0 card) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO tblMembershipCard0 (code, issueDate, tier, points, idCustomer, idSaleStaff) VALUES (?,?,?,?,?,?)",
                Statement.RETURN_GENERATED_KEYS)) {
            card.setCode(nextCode("tblMembershipCard0", "TV", 4));
            ps.setString(1, card.getCode());
            ps.setDate(2, Date.valueOf(card.getIssueDate()));
            ps.setString(3, card.getTier());
            ps.setInt(4, card.getPoints());
            ps.setInt(5, card.getCustomer().getId());
            ps.setInt(6, card.getIssuedBy().getId());
            ps.executeUpdate();
            card.setId(generatedId(ps));
            return true;
        } catch (SQLException e) {
            return false;
        }
    }

    /** Cong diem va cap nhat hang the (dung trong giao dich thanh toan). */
    public boolean addPoints(int idCard, int points) throws SQLException {
        int current;
        try (PreparedStatement ps = con.prepareStatement("SELECT points FROM tblMembershipCard0 WHERE id = ?")) {
            ps.setInt(1, idCard);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return false;
                current = rs.getInt(1);
            }
        }
        int total = current + points;
        try (PreparedStatement ps = con.prepareStatement("UPDATE tblMembershipCard0 SET points = ?, tier = ? WHERE id = ?")) {
            ps.setInt(1, total);
            ps.setString(2, MembershipCard0.tierOf(total));
            ps.setInt(3, idCard);
            return ps.executeUpdate() == 1;
        }
    }
}

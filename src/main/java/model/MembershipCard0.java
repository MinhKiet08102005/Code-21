package model;

import java.math.BigDecimal;
import java.time.LocalDate;

/** The thanh vien cua khach hang. */
public class MembershipCard0 implements java.io.Serializable {
    private int id;
    private String code;
    private LocalDate issueDate;
    private String tier;
    private int points;
    private Customer0 customer;
    private SaleStaff0 issuedBy;

    public MembershipCard0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public LocalDate getIssueDate() { return issueDate; }
    public void setIssueDate(LocalDate issueDate) { this.issueDate = issueDate; }
    public String getTier() { return tier; }
    public void setTier(String tier) { this.tier = tier; }
    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }
    public Customer0 getCustomer() { return customer; }
    public void setCustomer(Customer0 customer) { this.customer = customer; }
    public SaleStaff0 getIssuedBy() { return issuedBy; }
    public void setIssuedBy(SaleStaff0 issuedBy) { this.issuedBy = issuedBy; }

    /** Ti le giam gia theo hang the: Vang 10%, Bac 5%. */
    public BigDecimal getDiscountRate() {
        return "Vàng".equals(tier) ? new BigDecimal("0.10") : new BigDecimal("0.05");
    }

    /** Hang the theo diem tich luy: tu 100 diem len hang Vang. */
    public static String tierOf(int points) {
        return points >= 100 ? "Vàng" : "Bạc";
    }
}

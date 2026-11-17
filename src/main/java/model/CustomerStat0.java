package model;

import java.math.BigDecimal;

/** Thong ke khach hang: so lan thanh toan va tong chi tieu. */
public class CustomerStat0 extends Customer0 {
    private int visitCount;
    private BigDecimal totalSpent;

    public CustomerStat0() {}

    public int getVisitCount() { return visitCount; }
    public void setVisitCount(int visitCount) { this.visitCount = visitCount; }
    public BigDecimal getTotalSpent() { return totalSpent; }
    public void setTotalSpent(BigDecimal totalSpent) { this.totalSpent = totalSpent; }
}

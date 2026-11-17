package model;

import java.math.BigDecimal;

/** Thong ke mon an: so luong ban va doanh thu trong khoang thoi gian. */
public class DishStat0 extends Dish0 {
    private int quantitySold;
    private BigDecimal revenue;

    public DishStat0() {}

    public int getQuantitySold() { return quantitySold; }
    public void setQuantitySold(int quantitySold) { this.quantitySold = quantitySold; }
    public BigDecimal getRevenue() { return revenue; }
    public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }
}

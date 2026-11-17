package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Hoa don thanh toan tai ban. */
public class Payment0 implements java.io.Serializable {
    private int id;
    private String code;
    private LocalDateTime paymentTime;
    private BigDecimal totalAmount;
    private BigDecimal discount;
    private String paymentMethod;
    private Order0 order;
    private SaleStaff0 saleStaff;
    private Customer0 customer;

    public Payment0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public LocalDateTime getPaymentTime() { return paymentTime; }
    public void setPaymentTime(LocalDateTime paymentTime) { this.paymentTime = paymentTime; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public BigDecimal getDiscount() { return discount; }
    public void setDiscount(BigDecimal discount) { this.discount = discount; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public Order0 getOrder() { return order; }
    public void setOrder(Order0 order) { this.order = order; }
    public SaleStaff0 getSaleStaff() { return saleStaff; }
    public void setSaleStaff(SaleStaff0 saleStaff) { this.saleStaff = saleStaff; }
    public Customer0 getCustomer() { return customer; }
    public void setCustomer(Customer0 customer) { this.customer = customer; }

    /** So tien khach phai tra = tong tien - giam gia. */
    public BigDecimal getFinalAmount() {
        return totalAmount.subtract(discount == null ? BigDecimal.ZERO : discount);
    }
}

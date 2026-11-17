package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** Don goi mon (tai ban hoac truc tuyen). */
public class Order0 implements java.io.Serializable {
    private int id;
    private String code;
    private LocalDateTime orderTime;
    private String status;
    private String orderType;
    private String note;
    private DiningTable0 table;
    private SaleStaff0 saleStaff;
    private Customer0 customer;
    private List<OrderDetail0> details = new ArrayList<>();

    public Order0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public LocalDateTime getOrderTime() { return orderTime; }
    public void setOrderTime(LocalDateTime orderTime) { this.orderTime = orderTime; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getOrderType() { return orderType; }
    public void setOrderType(String orderType) { this.orderType = orderType; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public DiningTable0 getTable() { return table; }
    public void setTable(DiningTable0 table) { this.table = table; }
    public SaleStaff0 getSaleStaff() { return saleStaff; }
    public void setSaleStaff(SaleStaff0 saleStaff) { this.saleStaff = saleStaff; }
    public Customer0 getCustomer() { return customer; }
    public void setCustomer(Customer0 customer) { this.customer = customer; }
    public List<OrderDetail0> getDetails() { return details; }
    public void setDetails(List<OrderDetail0> details) { this.details = details; }

    /** Tong tien cac dong chi tiet. */
    public BigDecimal getTotalAmount() {
        BigDecimal s = BigDecimal.ZERO;
        if (details != null) for (OrderDetail0 d : details) s = s.add(d.getAmount());
        return s;
    }
}

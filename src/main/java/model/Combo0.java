package model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/** Thuc don combo gom nhieu mon an. */
public class Combo0 implements java.io.Serializable {
    private int id;
    private String code;
    private String name;
    private BigDecimal price;
    private String description;
    private String status;
    private ManagementStaff0 createdBy;
    private List<ComboDetail0> details = new ArrayList<>();

    public Combo0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public ManagementStaff0 getCreatedBy() { return createdBy; }
    public void setCreatedBy(ManagementStaff0 createdBy) { this.createdBy = createdBy; }
    public List<ComboDetail0> getDetails() { return details; }
    public void setDetails(List<ComboDetail0> details) { this.details = details; }

    /** Tong gia neu mua le cac mon trong combo. */
    public BigDecimal getOriginalPrice() {
        BigDecimal s = BigDecimal.ZERO;
        if (details != null) for (ComboDetail0 d : details)
            s = s.add(d.getDish().getSellingPrice().multiply(BigDecimal.valueOf(d.getQuantity())));
        return s;
    }
}

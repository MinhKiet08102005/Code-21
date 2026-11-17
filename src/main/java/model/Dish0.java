package model;

import java.math.BigDecimal;

/** Mon an (muc thuc don). */
public class Dish0 implements java.io.Serializable {
    private int id;
    private String code;
    private String name;
    private BigDecimal sellingPrice;
    private String description;
    private String imagePath;
    private String status;
    private DishCategory0 category;
    private ManagementStaff0 createdBy;

    public Dish0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public BigDecimal getSellingPrice() { return sellingPrice; }
    public void setSellingPrice(BigDecimal sellingPrice) { this.sellingPrice = sellingPrice; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public DishCategory0 getCategory() { return category; }
    public void setCategory(DishCategory0 category) { this.category = category; }
    public ManagementStaff0 getCreatedBy() { return createdBy; }
    public void setCreatedBy(ManagementStaff0 createdBy) { this.createdBy = createdBy; }
}

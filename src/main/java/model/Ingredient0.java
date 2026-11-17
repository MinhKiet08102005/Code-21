package model;

import java.math.BigDecimal;

/** Nguyen lieu. */
public class Ingredient0 implements java.io.Serializable {
    private int id;
    private String code;
    private String name;
    private String unit;
    private BigDecimal stockQuantity;
    private String description;

    public Ingredient0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public BigDecimal getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(BigDecimal stockQuantity) { this.stockQuantity = stockQuantity; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}

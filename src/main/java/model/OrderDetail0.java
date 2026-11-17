package model;

import java.math.BigDecimal;

/** Mot dong trong don goi mon: mot mon an hoac mot combo. */
public class OrderDetail0 implements java.io.Serializable {
    private int id;
    private int orderId;
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal amount;
    private Dish0 dish;
    private Combo0 combo;

    public OrderDetail0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public Dish0 getDish() { return dish; }
    public void setDish(Dish0 dish) { this.dish = dish; }
    public Combo0 getCombo() { return combo; }
    public void setCombo(Combo0 combo) { this.combo = combo; }

    public String getItemName() {
        return dish != null ? dish.getName() : (combo != null ? combo.getName() + " (combo)" : "");
    }

    public BigDecimal calculateAmount() {
        amount = unitPrice.multiply(BigDecimal.valueOf(quantity));
        return amount;
    }
}

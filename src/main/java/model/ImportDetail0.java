package model;

import java.math.BigDecimal;

/** Mot dong nguyen lieu trong phieu nhap. */
public class ImportDetail0 implements java.io.Serializable {
    private int id;
    private BigDecimal quantity;
    private BigDecimal unitPrice;
    private BigDecimal amount;
    private ImportInvoice0 importInvoice;
    private Ingredient0 ingredient;

    public ImportDetail0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public BigDecimal getQuantity() { return quantity; }
    public void setQuantity(BigDecimal quantity) { this.quantity = quantity; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public ImportInvoice0 getImportInvoice() { return importInvoice; }
    public void setImportInvoice(ImportInvoice0 importInvoice) { this.importInvoice = importInvoice; }
    public Ingredient0 getIngredient() { return ingredient; }
    public void setIngredient(Ingredient0 ingredient) { this.ingredient = ingredient; }

    /** Thanh tien = so luong x don gia (thuoc tinh dan xuat). */
    public BigDecimal calculateAmount() {
        amount = quantity.multiply(unitPrice);
        return amount;
    }
}

package model;

import java.math.BigDecimal;

/** Thong ke nguyen lieu: so lan nhap, so luong va gia tri nhap. */
public class IngredientStat0 extends Ingredient0 {
    private int invoiceCount;
    private BigDecimal importQuantity;
    private BigDecimal importValue;

    public IngredientStat0() {}

    public int getInvoiceCount() { return invoiceCount; }
    public void setInvoiceCount(int invoiceCount) { this.invoiceCount = invoiceCount; }
    public BigDecimal getImportQuantity() { return importQuantity; }
    public void setImportQuantity(BigDecimal importQuantity) { this.importQuantity = importQuantity; }
    public BigDecimal getImportValue() { return importValue; }
    public void setImportValue(BigDecimal importValue) { this.importValue = importValue; }
}

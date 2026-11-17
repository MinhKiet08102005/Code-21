package model;

import java.math.BigDecimal;

/** Thong ke nha cung cap: so phieu nhap va tong gia tri nhap. */
public class SupplierStat0 extends Supplier0 {
    private int invoiceCount;
    private BigDecimal totalImport;

    public SupplierStat0() {}

    public int getInvoiceCount() { return invoiceCount; }
    public void setInvoiceCount(int invoiceCount) { this.invoiceCount = invoiceCount; }
    public BigDecimal getTotalImport() { return totalImport; }
    public void setTotalImport(BigDecimal totalImport) { this.totalImport = totalImport; }
}

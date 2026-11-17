package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** Phieu nhap nguyen lieu. */
public class ImportInvoice0 implements java.io.Serializable {
    private int id;
    private String code;
    private LocalDateTime importDate;
    private BigDecimal totalAmount;
    private Supplier0 supplier;
    private WarehouseStaff0 warehouseStaff;
    private List<ImportDetail0> details = new ArrayList<>();

    public ImportInvoice0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public LocalDateTime getImportDate() { return importDate; }
    public void setImportDate(LocalDateTime importDate) { this.importDate = importDate; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public Supplier0 getSupplier() { return supplier; }
    public void setSupplier(Supplier0 supplier) { this.supplier = supplier; }
    public WarehouseStaff0 getWarehouseStaff() { return warehouseStaff; }
    public void setWarehouseStaff(WarehouseStaff0 warehouseStaff) { this.warehouseStaff = warehouseStaff; }
    public List<ImportDetail0> getDetails() { return details; }
    public void setDetails(List<ImportDetail0> details) { this.details = details; }
}

package model;

import java.time.LocalDateTime;

/** Phieu dat ban truc tuyen. */
public class TableReservation0 implements java.io.Serializable {
    private int id;
    private String code;
    private LocalDateTime reservationTime;
    private int numberOfGuests;
    private String note;
    private String status;
    private LocalDateTime createdAt;
    private Customer0 customer;
    private DiningTable0 table;
    private SaleStaff0 saleStaff;

    public TableReservation0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public LocalDateTime getReservationTime() { return reservationTime; }
    public void setReservationTime(LocalDateTime reservationTime) { this.reservationTime = reservationTime; }
    public int getNumberOfGuests() { return numberOfGuests; }
    public void setNumberOfGuests(int numberOfGuests) { this.numberOfGuests = numberOfGuests; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public Customer0 getCustomer() { return customer; }
    public void setCustomer(Customer0 customer) { this.customer = customer; }
    public DiningTable0 getTable() { return table; }
    public void setTable(DiningTable0 table) { this.table = table; }
    public SaleStaff0 getSaleStaff() { return saleStaff; }
    public void setSaleStaff(SaleStaff0 saleStaff) { this.saleStaff = saleStaff; }
}

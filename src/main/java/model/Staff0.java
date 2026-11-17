package model;

/** Nhan vien nha hang (lop truu tuong), phan biet loai qua getRole(). */
public abstract class Staff0 extends User0 {
    private String position;

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    /** MANAGER, WAREHOUSE hoac SALE. */
    public abstract String getRole();
}

package util;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/** Ham dinh dang va kiem tra du lieu dung chung cho cac trang JSP. */
public final class Format0 {

    private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter D = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private Format0() {
    }

    private static DecimalFormat df(String pattern) {
        DecimalFormatSymbols s = new DecimalFormatSymbols(Locale.US);
        s.setGroupingSeparator('.');
        s.setDecimalSeparator(',');
        return new DecimalFormat(pattern, s);
    }

    /** 150000 -> "150.000 VNĐ" */
    public static String money(BigDecimal v) {
        return v == null ? "" : df("#,##0").format(v) + " VNĐ";
    }

    /** So luong: bo so 0 thua, vd 10.500 -> "10,5" */
    public static String qty(BigDecimal v) {
        return v == null ? "" : df("#,##0.###").format(v);
    }

    public static String dateTime(LocalDateTime t) {
        return t == null ? "" : t.format(DT);
    }

    public static String date(LocalDate d) {
        return d == null ? "" : d.format(D);
    }

    /** Thoat ky tu HTML. */
    public static String h(Object o) {
        if (o == null) return "";
        String s = o.toString();
        StringBuilder sb = new StringBuilder(s.length());
        for (char c : s.toCharArray()) {
            switch (c) {
                case '<': sb.append("&lt;"); break;
                case '>': sb.append("&gt;"); break;
                case '&': sb.append("&amp;"); break;
                case '"': sb.append("&quot;"); break;
                case '\'': sb.append("&#39;"); break;
                default: sb.append(c);
            }
        }
        return sb.toString();
    }

    public static boolean blank(String s) {
        return s == null || s.trim().isEmpty();
    }

    public static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    /** Doc so tien/so luong nhap tu form: chap nhan "150000", "150.000", "10,5". Sai dinh dang tra null. */
    public static BigDecimal parseNumber(String s) {
        if (blank(s)) return null;
        String t = s.trim().replace(" ", "");
        if (t.matches("\\d{1,3}(\\.\\d{3})+(,\\d+)?")) t = t.replace(".", "").replace(',', '.');
        else t = t.replace(',', '.');
        try {
            return new BigDecimal(t);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public static int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return def;
        }
    }

    /** So dien thoai Viet Nam: 10 chu so, bat dau bang 0. */
    public static boolean validPhone(String s) {
        return s != null && s.trim().matches("0\\d{9}");
    }

    public static boolean validEmail(String s) {
        return blank(s) || s.trim().matches("[^@\\s]+@[^@\\s]+\\.[^@\\s]+");
    }

    public static String nullIfBlank(String s) {
        return blank(s) ? null : s.trim();
    }
}

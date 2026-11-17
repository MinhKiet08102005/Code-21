package dao;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Properties;

/**
 * Lop DAO truu tuong: giu ket noi CSDL dung chung cho moi lop DAO con (theo thiet ke).
 * Lan ket noi dau tien se tu tao bang va nap du lieu mau neu CSDL con trong.
 */
public abstract class DAO0 {
    protected static Connection con;

    public DAO0() {
        synchronized (DAO0.class) {
            try {
                if (con == null || con.isClosed()) {
                    con = openConnection();
                    initDatabaseIfNeeded();
                }
            } catch (Exception e) {
                throw new IllegalStateException("Không kết nối được cơ sở dữ liệu: " + e.getMessage(), e);
            }
        }
    }

    private static Connection openConnection() throws Exception {
        Properties p = new Properties();
        try (InputStream in = DAO0.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) p.load(in);
        }
        String url = System.getProperty("db.url", p.getProperty("db.url"));
        String user = System.getProperty("db.user", p.getProperty("db.user", ""));
        String pass = System.getProperty("db.password", p.getProperty("db.password", ""));
        if (url.startsWith("jdbc:h2:")) Class.forName("org.h2.Driver");
        else if (url.startsWith("jdbc:mysql:")) Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, user, pass);
    }

    /** Neu chua co bang tblUser0 thi chay schema.sql va data.sql. */
    private static void initDatabaseIfNeeded() throws Exception {
        try (Statement st = con.createStatement()) {
            st.executeQuery("SELECT COUNT(*) FROM tblUser0").close();
            return;
        } catch (SQLException notCreatedYet) {
            // tiep tuc tao bang
        }
        runScript("database/schema.sql");
        runScript("database/data.sql");
    }

    private static void runScript(String resource) throws Exception {
        StringBuilder sb = new StringBuilder();
        try (InputStream in = DAO0.class.getClassLoader().getResourceAsStream(resource)) {
            if (in == null) throw new IllegalStateException("Thiếu tệp " + resource);
            BufferedReader r = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
            String line;
            while ((line = r.readLine()) != null) {
                if (line.trim().startsWith("--")) continue;
                sb.append(line).append('\n');
            }
        }
        try (Statement st = con.createStatement()) {
            for (String sql : sb.toString().split(";")) {
                if (!sql.trim().isEmpty()) st.execute(sql);
            }
        }
    }

    // ------------------------------------------------------------------ tien ich dung chung

    /** Sinh ma tiep theo, vd prefix "PN", do dai 4 -> PN0102 (lay so lon nhat dang co + 1). */
    protected String nextCode(String table, String prefix, int width) throws SQLException {
        int max = 0;
        try (PreparedStatement ps = con.prepareStatement("SELECT code FROM " + table + " WHERE code LIKE ?")) {
            ps.setString(1, prefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    try {
                        max = Math.max(max, Integer.parseInt(rs.getString(1).substring(prefix.length())));
                    } catch (NumberFormatException ignore) {
                    }
                }
            }
        }
        return prefix + String.format("%0" + width + "d", max + 1);
    }

    protected static int generatedId(PreparedStatement ps) throws SQLException {
        try (ResultSet k = ps.getGeneratedKeys()) {
            return k.next() ? k.getInt(1) : 0;
        }
    }

    protected static LocalDateTime toLdt(Timestamp t) {
        return t == null ? null : t.toLocalDateTime();
    }

    protected static Timestamp toTs(LocalDateTime t) {
        return t == null ? null : Timestamp.valueOf(t);
    }

    protected static BigDecimal nz(BigDecimal b) {
        return b == null ? BigDecimal.ZERO : b;
    }

    protected static void rollbackQuietly() {
        try {
            con.rollback();
        } catch (SQLException ignore) {
        }
    }

    protected static void autoCommitQuietly() {
        try {
            con.setAutoCommit(true);
        } catch (SQLException ignore) {
        }
    }
}

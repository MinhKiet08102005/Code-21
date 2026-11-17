package app;

import java.awt.Desktop;
import java.io.File;
import java.net.ServerSocket;
import java.net.URI;

import org.apache.catalina.Context;
import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

/**
 * Chay demo bang Tomcat nhung (khong thuoc thiet ke he thong, chi de khoi dong nhanh).
 * Lenh: mvn compile exec:java   (hoac chay run.bat). Mo trinh duyet: http://localhost:8080
 */
public class Launcher {

    public static void main(String[] args) throws Exception {
        File webapp = new File("src/main/webapp");
        File classes = new File("target/classes");
        if (!webapp.isDirectory()) {
            System.err.println("Hay chay lenh trong thu muc demo (noi co pom.xml).");
            return;
        }
        new File("data").mkdirs();
        int port = freePort(Integer.parseInt(System.getProperty("port", "8080")));

        Tomcat tomcat = new Tomcat();
        tomcat.setBaseDir(new File("target/tomcat").getAbsolutePath());
        tomcat.setPort(port);
        tomcat.getConnector().setURIEncoding("UTF-8");

        // Khi chay bang mvn exec:java, cac lop Tomcat/H2 nam trong class loader cua Maven exec,
        // nen phai dat class loader nay lam cha cua ung dung web.
        ClassLoader loader = Launcher.class.getClassLoader();
        Thread.currentThread().setContextClassLoader(loader);
        tomcat.getServer().setParentClassLoader(loader);
        Context ctx = tomcat.addWebapp("", webapp.getAbsolutePath());
        ctx.setParentClassLoader(loader);
        WebResourceRoot resources = new StandardRoot(ctx);
        resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes", classes.getAbsolutePath(), "/"));
        ctx.setResources(resources);

        tomcat.start();
        String url = "http://localhost:" + port + "/";
        System.out.println();
        System.out.println("==============================================================");
        System.out.println("  He thong quan li nha hang dang chay tai: " + url);
        System.out.println("  Tai khoan: quanly / kho / banhang  - mat khau 123456");
        System.out.println("  Nhan Ctrl+C de dung.");
        System.out.println("==============================================================");
        try {
            if (!Boolean.getBoolean("noBrowser") && Desktop.isDesktopSupported()) Desktop.getDesktop().browse(new URI(url));
        } catch (Exception ignore) {
        }
        tomcat.getServer().await();
    }

    private static int freePort(int start) {
        for (int p = start; p < start + 20; p++) {
            try (ServerSocket s = new ServerSocket(p)) {
                return p;
            } catch (Exception busy) {
                // thu cong tiep theo
            }
        }
        return start;
    }
}

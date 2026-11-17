package util;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

import jakarta.servlet.http.Part;

/** Kiem tra va luu anh mon an tai len (chi nhan JPG/PNG, toi da 2MB). */
public final class ImageUpload0 {

    public static final long MAX_SIZE = 2L * 1024 * 1024;

    private ImageUpload0() {
    }

    /** Co chon tep hay khong. */
    public static boolean hasFile(Part part) {
        return part != null && part.getSize() > 0 && !Format0.blank(part.getSubmittedFileName());
    }

    /** Tra ve thong bao loi, hoac null neu tep hop le. */
    public static String validate(Part part) {
        if (!hasFile(part)) return null;
        String ext = extension(part.getSubmittedFileName());
        if (!(ext.equals("jpg") || ext.equals("jpeg") || ext.equals("png"))) return "Chỉ chấp nhận ảnh JPG hoặc PNG dưới 2MB";
        if (part.getSize() > MAX_SIZE) return "Chỉ chấp nhận ảnh JPG hoặc PNG dưới 2MB";
        return null;
    }

    /** Luu vao thu muc uploads cua ung dung, tra ve duong dan tuong doi (vd uploads/dish_1700000000.jpg). */
    public static String save(Part part, String uploadDir) throws IOException {
        File dir = new File(uploadDir);
        if (!dir.exists() && !dir.mkdirs()) throw new IOException("Không tạo được thư mục ảnh");
        String name = "dish_" + System.currentTimeMillis() + "." + extension(part.getSubmittedFileName());
        try (InputStream in = part.getInputStream()) {
            Files.copy(in, new File(dir, name).toPath(), StandardCopyOption.REPLACE_EXISTING);
        }
        return "uploads/" + name;
    }

    public static void deleteQuietly(String uploadRoot, String relativePath) {
        if (relativePath == null) return;
        File f = new File(uploadRoot, relativePath.replace("uploads/", ""));
        if (f.isFile()) f.delete();
    }

    private static String extension(String fileName) {
        int i = fileName == null ? -1 : fileName.lastIndexOf('.');
        return i < 0 ? "" : fileName.substring(i + 1).toLowerCase();
    }
}

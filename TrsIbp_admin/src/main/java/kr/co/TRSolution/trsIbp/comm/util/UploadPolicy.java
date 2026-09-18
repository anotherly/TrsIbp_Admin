package kr.co.TRSolution.trsIbp.comm.util;

import java.awt.image.BufferedImage;
import java.io.InputStream;
import java.util.*;
import java.util.regex.Pattern;

import javax.imageio.ImageIO;

import org.springframework.web.multipart.MultipartFile;

public final class UploadPolicy {

    // 업무상 허용 확장자만 남기세요.
    private static final Set<String> ALLOWED_EXT = new HashSet<>(Arrays.asList(
        "pdf","hwp","hwpx","doc","docx","xls","xlsx","ppt","pptx","txt",
        "jpg","jpeg","png","gif","webp","zip"
    ));

    private static final Set<String> ALLOWED_IMAGE_EXT = new HashSet<>(Arrays.asList(
        "jpg", "jpeg", "png", "gif"
    ));

    // 원본 파일명에 경로/이상문자 섞이는 것 방지(Windows/Unix 공통)
    private static final Pattern BAD_CHARS = Pattern.compile("[\\\\/\\r\\n\\t\\u0000]");

    private UploadPolicy() {}

    public static String extractSafeOriginalName(String originalFilename) {
        if (originalFilename == null) return "";
        String onlyName = originalFilename;
        int slash = Math.max(onlyName.lastIndexOf('/'), onlyName.lastIndexOf('\\'));
        if (slash >= 0) onlyName = onlyName.substring(slash + 1);
        return BAD_CHARS.matcher(onlyName).replaceAll("");
    }

    public static String extractSafeExt(String originalFilename) {
        if (originalFilename == null) return "";
        String onlyName = extractSafeOriginalName(originalFilename);
        int dot = onlyName.lastIndexOf('.');
        if (dot < 0) return "";
        return onlyName.substring(dot + 1).toLowerCase(Locale.ROOT);
    }

    public static void validate(MultipartFile f) {

        if (f == null || f.isEmpty()) {
            throw new IllegalArgumentException("첨부파일이 없습니다.");
        }

        String ext = extractSafeExt(f.getOriginalFilename());
        if (!ALLOWED_EXT.contains(ext)) {
            throw new IllegalArgumentException("허용되지 않는 파일 확장자입니다. (" + ext + ")");
        }

        // 필요 시 용량 제한(중복 방지 차원)
        long max = 10_000_000L; // 10MB (현재 설정과 동일)
        if (f.getSize() > max) {
            throw new IllegalArgumentException("파일 용량이 허용치를 초과했습니다.");
        }
    }

    public static void validateImage(MultipartFile f) throws Exception {
        if (f == null || f.isEmpty()) {
            throw new IllegalArgumentException("프로필 사진 파일이 없습니다.");
        }
        String ext = extractSafeExt(f.getOriginalFilename());
        if (!ALLOWED_IMAGE_EXT.contains(ext)) {
            throw new IllegalArgumentException("프로필 사진은 JPG, PNG, GIF 형식만 등록할 수 있습니다.");
        }
        if (f.getSize() > 5_000_000L) {
            throw new IllegalArgumentException("프로필 사진은 5MB를 초과할 수 없습니다.");
        }
        try (InputStream inputStream = f.getInputStream()) {
            BufferedImage image = ImageIO.read(inputStream);
            if (image == null || image.getWidth() <= 0 || image.getHeight() <= 0) {
                throw new IllegalArgumentException("정상적인 이미지 파일이 아닙니다.");
            }
        }
    }
}

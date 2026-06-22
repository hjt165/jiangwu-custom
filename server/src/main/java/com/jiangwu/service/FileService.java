package com.jiangwu.service;

import com.jiangwu.exception.BusinessException;
import com.jiangwu.exception.ErrorCode;
import com.jiangwu.repository.OrderRepository;
import com.jiangwu.repository.ProductRepository;
import com.jiangwu.utils.CurrentUserUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * 文件上传服务
 */
@Slf4j
@Service
public class FileService {

    @Value("${file.upload-dir:./uploads}")
    private String uploadDir;

    @Value("${file.max-size:10485760}")
    private long maxSize;

    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;
    private final CurrentUserUtil currentUserUtil;

    public FileService(ProductRepository productRepository, OrderRepository orderRepository, CurrentUserUtil currentUserUtil) {
        this.productRepository = productRepository;
        this.orderRepository = orderRepository;
        this.currentUserUtil = currentUserUtil;
    }

    private static final List<String> ALLOWED_IMAGE_TYPES = Arrays.asList(
            "image/jpeg", "image/png", "image/gif", "image/webp"
    );

    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList(
            ".jpg", ".jpeg", ".png", ".gif", ".webp"
    );

    /**
     * 上传单个文件
     */
    public String uploadFile(MultipartFile file) {
        validateFile(file);

        try {
            String fileName = generateFileName(file);
            Path targetPath = getTargetPath(fileName);

            Files.createDirectories(targetPath.getParent());
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            log.info("文件上传成功: {}", fileName);
            return "/uploads/" + fileName;
        } catch (IOException e) {
            log.error("文件上传失败", e);
            throw new BusinessException(ErrorCode.FILE_UPLOAD_FAILED);
        }
    }

    /**
     * 上传多个文件
     */
    public List<String> uploadFiles(MultipartFile[] files) {
        return Arrays.stream(files)
                .map(this::uploadFile)
                .toList();
    }

    /**
     * 验证文件
     */
    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ErrorCode.FILE_UPLOAD_FAILED);
        }

        if (file.getSize() > maxSize) {
            throw new BusinessException(ErrorCode.FILE_SIZE_EXCEEDED);
        }

        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_IMAGE_TYPES.contains(contentType.toLowerCase())) {
            throw new BusinessException(ErrorCode.FILE_TYPE_NOT_ALLOWED);
        }

        String originalName = file.getOriginalFilename();
        if (originalName != null) {
            String ext = originalName.toLowerCase();
            int dotIndex = ext.lastIndexOf('.');
            if (dotIndex > 0) {
                ext = ext.substring(dotIndex);
            }
            if (!ALLOWED_EXTENSIONS.contains(ext)) {
                throw new BusinessException(ErrorCode.FILE_TYPE_NOT_ALLOWED);
            }
        }
    }

    /**
     * 生成唯一文件名
     */
    private String generateFileName(MultipartFile file) {
        String originalName = file.getOriginalFilename();
        String ext = "";
        if (originalName != null) {
            int dotIndex = originalName.lastIndexOf('.');
            if (dotIndex > 0) {
                ext = originalName.substring(dotIndex);
            }
        }

        String dateDir = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        String uuid = UUID.randomUUID().toString().replace("-", "");

        return dateDir + "/" + uuid + ext;
    }

    /**
     * 获取目标路径
     */
    private Path getTargetPath(String fileName) {
        return Paths.get(uploadDir, fileName);
    }

    /**
     * 删除文件
     */
    public boolean deleteFile(String fileUrl) {
        try {
            if (fileUrl == null || !fileUrl.startsWith("/uploads/")) {
                return false;
            }

            Long currentUserId = getCurrentUserId();
            if (currentUserId == null) {
                log.warn("删除文件失败: 未获取到当前用户ID");
                return false;
            }

            boolean isOwner = productRepository.existsByCoverImageAndArtisanUserId(fileUrl, currentUserId) > 0
                    || orderRepository.existsByReferenceImageAndUserId(fileUrl, currentUserId) > 0;
            if (!isOwner) {
                log.warn("删除文件失败: 用户{}无权删除文件{}", currentUserId, fileUrl);
                throw new BusinessException(ErrorCode.FORBIDDEN);
            }

            String fileName = fileUrl.substring("/uploads/".length());
            Path filePath = Paths.get(uploadDir, fileName);
            return Files.deleteIfExists(filePath);
        } catch (BusinessException e) {
            throw e;
        } catch (IOException e) {
            log.error("删除文件失败: {}", fileUrl, e);
            return false;
        }
    }

    private Long getCurrentUserId() {
        try {
            ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs == null) return null;
            HttpServletRequest request = attrs.getRequest();
            return currentUserUtil.extractUserIdOrNull(request);
        } catch (Exception e) {
            log.warn("获取当前用户ID失败", e);
        }
        return null;
    }
}

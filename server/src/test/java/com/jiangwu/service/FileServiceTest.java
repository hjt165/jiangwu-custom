package com.jiangwu.service;

import com.jiangwu.exception.BusinessException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.util.ReflectionTestUtils;

import java.io.ByteArrayInputStream;
import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class FileServiceTest {

    @InjectMocks private FileService fileService;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(fileService, "uploadDir", "test-uploads");
        ReflectionTestUtils.setField(fileService, "maxSize", 10485760L); // 10MB
    }

    // ==================== 文件验证测试 ====================

    @Test
    void uploadFile_EmptyFile_ThrowsException() {
        MockMultipartFile emptyFile = new MockMultipartFile(
                "file", "test.jpg", "image/jpeg", new byte[0]);

        assertThrows(BusinessException.class,
                () -> fileService.uploadFile(emptyFile));
    }

    @Test
    void uploadFile_NullFile_ThrowsException() {
        assertThrows(BusinessException.class,
                () -> fileService.uploadFile(null));
    }

    @Test
    void uploadFile_WrongContentType_ThrowsException() {
        MockMultipartFile textFile = new MockMultipartFile(
                "file", "test.txt", "text/plain", "hello".getBytes());

        assertThrows(BusinessException.class,
                () -> fileService.uploadFile(textFile));
    }

    @Test
    void uploadFile_WrongExtension_ThrowsException() {
        MockMultipartFile bmpFile = new MockMultipartFile(
                "file", "test.bmp", "image/bmp", new byte[]{1, 2, 3});

        assertThrows(BusinessException.class,
                () -> fileService.uploadFile(bmpFile));
    }

    @Test
    void uploadFile_ExceedsMaxSize_ThrowsException() {
        ReflectionTestUtils.setField(fileService, "maxSize", 100L); // 100 bytes

        byte[] largeData = new byte[200];
        MockMultipartFile largeFile = new MockMultipartFile(
                "file", "large.jpg", "image/jpeg", largeData);

        assertThrows(BusinessException.class,
                () -> fileService.uploadFile(largeFile));
    }

    // ==================== 有效文件上传 ====================

    @Test
    void uploadFile_ValidJpg_ReturnsUrl() {
        MockMultipartFile jpgFile = new MockMultipartFile(
                "file", "photo.jpg", "image/jpeg", new byte[]{1, 2, 3, 4});

        String result = fileService.uploadFile(jpgFile);

        assertTrue(result.startsWith("/uploads/"));
        assertTrue(result.endsWith(".jpg"));
    }

    @Test
    void uploadFile_ValidPng_ReturnsUrl() {
        MockMultipartFile pngFile = new MockMultipartFile(
                "file", "image.png", "image/png", new byte[]{1, 2, 3, 4});

        String result = fileService.uploadFile(pngFile);

        assertTrue(result.startsWith("/uploads/"));
        assertTrue(result.endsWith(".png"));
    }

    @Test
    void uploadFile_ValidWebp_ReturnsUrl() {
        MockMultipartFile webpFile = new MockMultipartFile(
                "file", "photo.webp", "image/webp", new byte[]{1, 2, 3, 4});

        String result = fileService.uploadFile(webpFile);

        assertTrue(result.startsWith("/uploads/"));
        assertTrue(result.endsWith(".webp"));
    }

    // ==================== 删除文件测试 ====================

    @Test
    void deleteFile_NullUrl_ReturnsFalse() {
        boolean result = fileService.deleteFile(null);
        assertFalse(result);
    }

    @Test
    void deleteFile_InvalidPrefix_ReturnsFalse() {
        boolean result = fileService.deleteFile("/other/path/file.jpg");
        assertFalse(result);
    }

    @Test
    void deleteFile_NonExistentFile_ReturnsFalse() {
        boolean result = fileService.deleteFile("/uploads/nonexistent.jpg");
        assertFalse(result);
    }
}

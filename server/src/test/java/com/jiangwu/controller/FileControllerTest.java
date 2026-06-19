package com.jiangwu.controller;

import com.jiangwu.exception.GlobalExceptionHandler;
import com.jiangwu.service.FileService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 文件控制器测试
 */
class FileControllerTest {

    private MockMvc mockMvc;
    private FileService fileService;

    @BeforeEach
    void setUp() {
        fileService = mock(FileService.class);

        FileController controller = new FileController(fileService);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void uploadFile_Success() throws Exception {
        when(fileService.uploadFile(any())).thenReturn("/uploads/2026/06/test.jpg");

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "test.jpg",
                "image/jpeg",
                "test image content".getBytes());

        mockMvc.perform(multipart("/file/upload").file(file))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.url").value("/uploads/2026/06/test.jpg"));
    }

    @Test
    void uploadFile_InvalidType_ReturnsError() throws Exception {
        when(fileService.uploadFile(any()))
                .thenThrow(new RuntimeException("文件类型不支持"));

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "test.txt",
                "text/plain",
                "test content".getBytes());

        mockMvc.perform(multipart("/file/upload").file(file))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.code").value(500));
    }

    @Test
    void uploadFile_TooLarge_ReturnsError() throws Exception {
        when(fileService.uploadFile(any()))
                .thenThrow(new RuntimeException("文件大小超出限制"));

        byte[] largeContent = new byte[11 * 1024 * 1024]; // 11MB
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "large.jpg",
                "image/jpeg",
                largeContent);

        mockMvc.perform(multipart("/file/upload").file(file))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.code").value(500));
    }

    @Test
    void deleteFile_Success() throws Exception {
        mockMvc.perform(delete("/file")
                        .param("url", "/uploads/2026/06/test.jpg"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }
}

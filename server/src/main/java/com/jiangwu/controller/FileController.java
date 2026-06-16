package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.service.FileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 文件上传控制器
 */
@Tag(name = "文件接口")
@RestController
@RequestMapping("/file")
@RequiredArgsConstructor
public class FileController {

    private final FileService fileService;

    /**
     * 上传单个文件
     */
    @Operation(summary = "上传单个文件")
    @PostMapping("/upload")
    public Result<Map<String, String>> uploadFile(@RequestParam("file") MultipartFile file) {
        String url = fileService.uploadFile(file);
        Map<String, String> data = new HashMap<>();
        data.put("url", url);
        return Result.success(data);
    }

    /**
     * 上传多个文件
     */
    @Operation(summary = "上传多个文件")
    @PostMapping("/upload/batch")
    public Result<Map<String, List<String>>> uploadFiles(@RequestParam("files") MultipartFile[] files) {
        List<String> urls = fileService.uploadFiles(files);
        Map<String, List<String>> data = new HashMap<>();
        data.put("urls", urls);
        return Result.success(data);
    }

    /**
     * 删除文件
     */
    @Operation(summary = "删除文件")
    @DeleteMapping
    public Result<Void> deleteFile(@RequestParam String url) {
        fileService.deleteFile(url);
        return Result.success(null);
    }
}

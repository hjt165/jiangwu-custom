package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.dto.response.ProductResponse;
import com.jiangwu.service.HistoryService;
import com.jiangwu.utils.JWTUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 浏览历史控制器
 */
@RestController
@RequestMapping("/history")
@RequiredArgsConstructor
public class HistoryController {

    private final HistoryService historyService;
    private final JWTUtil jwtUtil;

    /**
     * 记录浏览
     */
    @PostMapping("/record")
    public Result<Void> recordView(@RequestBody Map<String, Long> body, HttpServletRequest request) {
        Long userId = extractUserId(request);
        Long productId = body.get("productId");
        if (productId == null) {
            return Result.error(400, "productId 不能为空");
        }
        historyService.recordView(userId, productId);
        return Result.success();
    }

    /**
     * 获取浏览历史列表
     */
    @GetMapping("/list")
    public Result<List<ProductResponse>> getHistoryList(HttpServletRequest request) {
        Long userId = extractUserId(request);
        List<ProductResponse> list = historyService.getHistoryList(userId);
        return Result.success(list);
    }

    /**
     * 清空浏览历史
     */
    @DeleteMapping("/clear")
    public Result<Void> clearHistory(HttpServletRequest request) {
        Long userId = extractUserId(request);
        historyService.clearHistory(userId);
        return Result.success();
    }

    /**
     * 从请求中提取用户ID
     */
    private Long extractUserId(HttpServletRequest request) {
        String token = jwtUtil.extractToken(request.getHeader("Authorization"));
        return jwtUtil.parseUserId(token);
    }
}

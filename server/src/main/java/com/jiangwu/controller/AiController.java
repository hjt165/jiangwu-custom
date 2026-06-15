package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.entity.Customization;
import com.jiangwu.repository.CustomizationRepository;
import com.jiangwu.service.AiService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * AI 服务控制器 - 给 Flutter 前端调用
 */
@RestController
@RequestMapping("/ai")
@RequiredArgsConstructor
public class AiController {

    private final AiService aiService;
    private final CustomizationRepository customizationRepository;

    /**
     * 推荐手作人
     */
    @PostMapping("/recommend-artisan")
    public Result<Map<String, Object>> recommendArtisan(@RequestBody Map<String, Object> request) {
        String category = (String) request.get("category");
        String style = (String) request.get("style");
        double budgetMin = request.get("budgetMin") != null ? ((Number) request.get("budgetMin")).doubleValue() : 0;
        double budgetMax = request.get("budgetMax") != null ? ((Number) request.get("budgetMax")).doubleValue() : 99999;
        int deliveryDays = request.get("deliveryDays") != null ? ((Number) request.get("deliveryDays")).intValue() : 30;
        int topK = request.get("topK") != null ? ((Number) request.get("topK")).intValue() : 10;

        Map<String, Object> result = aiService.recommendArtisan(
                category, style, budgetMin, budgetMax, deliveryDays, topK
        );
        return Result.success(result);
    }

    /**
     * 推荐方案
     */
    @PostMapping("/recommend-solution")
    public Result<Map<String, Object>> recommendSolution(@RequestBody Map<String, Object> request) {
        String description = (String) request.get("description");
        String imageUrl = (String) request.get("imageUrl");
        String category = (String) request.get("category");
        double budget = request.get("budget") != null ? ((Number) request.get("budget")).doubleValue() : 5000;
        int topK = request.get("topK") != null ? ((Number) request.get("topK")).intValue() : 5;

        Map<String, Object> result = aiService.recommendSolution(
                description, imageUrl, category, budget, topK
        );
        return Result.success(result);
    }

    /**
     * 获取相似案例
     */
    @GetMapping("/similar/{caseId}")
    public Result<Map<String, Object>> getSimilarCases(
            @PathVariable String caseId,
            @RequestParam(defaultValue = "5") int topK) {
        Map<String, Object> result = aiService.getSimilarCases(caseId, topK);
        return Result.success(result);
    }

    /**
     * 分析图片
     */
    @PostMapping("/analyze-image")
    public Result<Map<String, Object>> analyzeImage(@RequestBody Map<String, Object> request) {
        // 注意: 实际使用时应通过 multipart 上传图片
        // 这里简化为接收 base64 编码的图片
        String imageBase64 = (String) request.get("imageBase64");
        String filename = (String) request.get("filename");
        String description = (String) request.get("description");

        if (imageBase64 == null || imageBase64.isEmpty()) {
            return Result.error(400, "请提供图片数据");
        }

        byte[] imageData = java.util.Base64.getDecoder().decode(imageBase64);
        Map<String, Object> result = aiService.analyzeImage(imageData, filename, description);
        return Result.success(result);
    }

    /**
     * 分析文字
     */
    @PostMapping("/analyze-text")
    public Result<Map<String, Object>> analyzeText(@RequestBody Map<String, Object> request) {
        String text = (String) request.get("text");
        String category = (String) request.get("category");

        if (text == null || text.isEmpty()) {
            return Result.error(400, "请提供文本内容");
        }

        Map<String, Object> result = aiService.analyzeText(text, category);
        return Result.success(result);
    }

    /**
     * AI 任务回调端点 (供 AI 服务调用)
     */
    @SuppressWarnings("unchecked")
    @PostMapping("/task/complete")
    public Result<Void> handleTaskComplete(@RequestBody Map<String, Object> payload) {
        String taskId = (String) payload.get("taskId");
        String status = (String) payload.get("status");
        Map<String, Object> result = (Map<String, Object>) payload.get("result");
        Long orderId = payload.get("orderId") != null ? ((Number) payload.get("orderId")).longValue() : null;

        if (orderId != null && "completed".equals(status) && result != null) {
            Customization customization = customizationRepository.findByOrderId(orderId);
            if (customization != null) {
                String suggestion = result.toString();
                customization.setAiSuggestion(suggestion);
                customizationRepository.updateById(customization);
            }
        }
        return Result.success(null);
    }
}

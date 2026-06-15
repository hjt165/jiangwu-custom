package com.jiangwu.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

/**
 * AI 服务客户端
 * 同步调用用 WebClient，耗时任务用 RabbitMQ
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiService {

    @Qualifier("aiServiceWebClient")
    private final WebClient aiServiceWebClient;

    private final RabbitTemplate rabbitTemplate;
    private final ObjectMapper objectMapper;

    private static final String AI_TASK_EXCHANGE = "ai.task.exchange";
    private static final String AI_TASK_ROUTING_KEY = "ai.task.image";

    /**
     * 分析图片 (同步)
     */
    public Map<String, Object> analyzeImage(byte[] imageData, String filename, String description) {
        try {
            String result = aiServiceWebClient.post()
                    .uri("/analyze/image")
                    .header("Content-Type", "multipart/form-data")
                    .bodyValue(buildMultipartBody(imageData, filename, description))
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            return objectMapper.readValue(result, Map.class);
        } catch (WebClientResponseException e) {
            log.error("AI 图片分析失败: {}", e.getMessage());
            return Map.of("error", e.getMessage());
        } catch (Exception e) {
            log.error("AI 图片分析异常: {}", e.getMessage());
            return Map.of("error", "AI 服务不可用");
        }
    }

    /**
     * 分析文字 (同步)
     */
    public Map<String, Object> analyzeText(String text, String category) {
        try {
            Map<String, String> formData = new HashMap<>();
            formData.put("text", text);
            if (category != null) {
                formData.put("category", category);
            }

            String result = aiServiceWebClient.post()
                    .uri("/analyze/text")
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .bodyValue(formData)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            return objectMapper.readValue(result, Map.class);
        } catch (Exception e) {
            log.error("AI 文字分析异常: {}", e.getMessage());
            return Map.of("error", "AI 服务不可用");
        }
    }

    /**
     * 多模态联合分析 (同步)
     */
    public Map<String, Object> analyzeMultimodal(byte[] imageData, String text, String category) {
        try {
            String result = aiServiceWebClient.post()
                    .uri("/analyze/multimodal")
                    .bodyValue(buildMultimodalBody(imageData, text, category))
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            return objectMapper.readValue(result, Map.class);
        } catch (Exception e) {
            log.error("AI 多模态分析异常: {}", e.getMessage());
            return Map.of("error", "AI 服务不可用");
        }
    }

    /**
     * 推荐手作人 (同步)
     */
    public Map<String, Object> recommendArtisan(String category, String style,
                                                 double budgetMin, double budgetMax,
                                                 int deliveryDays, int topK) {
        try {
            Map<String, Object> request = new HashMap<>();
            request.put("category", category);
            request.put("style", style != null ? style : "");
            request.put("budget_min", budgetMin);
            request.put("budget_max", budgetMax);
            request.put("delivery_days", deliveryDays);
            request.put("top_k", topK);

            String result = aiServiceWebClient.post()
                    .uri("/recommend/artisan")
                    .bodyValue(request)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            return objectMapper.readValue(result, Map.class);
        } catch (Exception e) {
            log.error("AI 手作人推荐异常: {}", e.getMessage());
            return Map.of("error", "AI 服务不可用");
        }
    }

    /**
     * 推荐方案 (同步)
     */
    public Map<String, Object> recommendSolution(String description, String imageUrl,
                                                  String category, double budget, int topK) {
        try {
            Map<String, Object> request = new HashMap<>();
            request.put("description", description != null ? description : "");
            request.put("image_url", imageUrl);
            request.put("category", category);
            request.put("budget", budget);
            request.put("top_k", topK);

            String result = aiServiceWebClient.post()
                    .uri("/recommend/solution")
                    .bodyValue(request)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            return objectMapper.readValue(result, Map.class);
        } catch (Exception e) {
            log.error("AI 方案推荐异常: {}", e.getMessage());
            return Map.of("error", "AI 服务不可用");
        }
    }

    /**
     * 获取相似案例 (同步)
     */
    public Map<String, Object> getSimilarCases(String caseId, int topK) {
        try {
            String result = aiServiceWebClient.get()
                    .uri("/rag/similar/{caseId}?top_k={topK}", caseId, topK)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            return objectMapper.readValue(result, Map.class);
        } catch (Exception e) {
            log.error("AI 相似案例检索异常: {}", e.getMessage());
            return Map.of("error", "AI 服务不可用");
        }
    }

    /**
     * 提交异步 AI 任务 (通过 RabbitMQ)
     */
    public String submitAsyncTask(String taskType, Map<String, Object> params) {
        String taskId = UUID.randomUUID().toString();

        Map<String, Object> message = new HashMap<>();
        message.put("taskId", taskId);
        message.put("taskType", taskType);
        message.put("params", params);

        try {
            rabbitTemplate.convertAndSend(AI_TASK_EXCHANGE, AI_TASK_ROUTING_KEY, message);
            log.info("AI 异步任务已提交: taskId={}, type={}", taskId, taskType);
        } catch (Exception e) {
            log.error("AI 异步任务提交失败: {}", e.getMessage());
            return null;
        }

        return taskId;
    }

    private Map<String, Object> buildMultipartBody(byte[] imageData, String filename, String description) {
        Map<String, Object> body = new HashMap<>();
        body.put("file", Map.of("data", imageData, "filename", filename));
        if (description != null) {
            body.put("description", description);
        }
        return body;
    }

    private Map<String, Object> buildMultimodalBody(byte[] imageData, String text, String category) {
        Map<String, Object> body = new HashMap<>();
        if (imageData != null) {
            body.put("file", Map.of("data", imageData));
        }
        if (text != null) {
            body.put("text", text);
        }
        if (category != null) {
            body.put("category", category);
        }
        return body;
    }
}

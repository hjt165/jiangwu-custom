package com.jiangwu.listener;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jiangwu.config.RabbitMQConfig;
import com.jiangwu.entity.Customization;
import com.jiangwu.repository.CustomizationRepository;
import com.jiangwu.service.AiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * AI 任务消息监听器
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AiTaskListener {

    private final AiService aiService;
    private final ObjectMapper objectMapper;
    private final CustomizationRepository customizationRepository;

    /**
     * 监听 AI 任务队列 - 接收任务请求并转发到 AI 服务
     */
    @RabbitListener(queues = RabbitMQConfig.AI_TASK_QUEUE)
    public void handleAiTask(Map<String, Object> message) {
        String taskId = (String) message.get("taskId");
        String taskType = (String) message.get("taskType");
        Map<String, Object> params = (Map<String, Object>) message.get("params");

        log.info("收到 AI 任务: taskId={}, type={}", taskId, taskType);

        try {
            Map<String, Object> result;
            switch (taskType) {
                case "image_analysis":
                    byte[] imageData = (byte[]) params.get("imageData");
                    String filename = (String) params.get("filename");
                    result = aiService.analyzeImage(imageData, filename, null);
                    break;
                case "recommend_artisan":
                    result = aiService.recommendArtisan(
                            (String) params.get("category"),
                            (String) params.get("style"),
                            params.get("budgetMin") != null ? ((Number) params.get("budgetMin")).doubleValue() : 0,
                            params.get("budgetMax") != null ? ((Number) params.get("budgetMax")).doubleValue() : 99999,
                            params.get("deliveryDays") != null ? ((Number) params.get("deliveryDays")).intValue() : 30,
                            params.get("topK") != null ? ((Number) params.get("topK")).intValue() : 10
                    );
                    break;
                default:
                    log.warn("未知 AI 任务类型: {}", taskType);
                    result = Map.of("error", "未知任务类型: " + taskType);
            }

            log.info("AI 任务完成: taskId={}, result keys={}", taskId, result.keySet());
        } catch (Exception e) {
            log.error("AI 任务执行失败: taskId={}, error={}", taskId, e.getMessage());
        }
    }

    /**
     * 监听 AI 任务完成回调队列 - AI 服务异步任务完成后回调
     */
    @SuppressWarnings("unchecked")
    @RabbitListener(queues = RabbitMQConfig.AI_TASK_COMPLETE_QUEUE)
    public void handleAiTaskComplete(Map<String, Object> message) {
        String taskId = (String) message.get("taskId");
        String status = (String) message.get("status");
        Map<String, Object> result = (Map<String, Object>) message.get("result");
        Long orderId = message.get("orderId") != null ? ((Number) message.get("orderId")).longValue() : null;

        log.info("AI 任务回调: taskId={}, status={}", taskId, status);

        if (orderId != null && "completed".equals(status) && result != null) {
            try {
                Customization customization = customizationRepository.findByOrderId(orderId);
                if (customization != null) {
                    String suggestion = objectMapper.writeValueAsString(result);
                    customization.setAiSuggestion(suggestion);
                    customizationRepository.updateById(customization);
                    log.info("AI 建议已保存: orderId={}", orderId);
                }
            } catch (Exception e) {
                log.error("保存 AI 建议失败: orderId={}, error={}", orderId, e.getMessage());
            }
        }
    }
}

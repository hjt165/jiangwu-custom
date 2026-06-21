package com.jiangwu.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AiServiceTest {

    @Mock private WebClient aiServiceWebClient;
    @Mock private RabbitTemplate rabbitTemplate;
    @Mock private ObjectMapper objectMapper;
    @InjectMocks private AiService aiService;

    // ==================== 异步任务提交 ====================

    @Test
    void submitAsyncTask_Success() {
        doNothing().when(rabbitTemplate).convertAndSend(anyString(), anyString(), any(Map.class));

        String taskId = aiService.submitAsyncTask("image_analysis", Map.of("imageId", "123"));

        assertNotNull(taskId);
        assertFalse(taskId.isEmpty());
        verify(rabbitTemplate).convertAndSend(anyString(), anyString(), any(Map.class));
    }

    @Test
    void submitAsyncTask_RabbitMQFailure_ReturnsNull() {
        doThrow(new RuntimeException("RabbitMQ unavailable"))
                .when(rabbitTemplate).convertAndSend(anyString(), anyString(), any(Map.class));

        String taskId = aiService.submitAsyncTask("image_analysis", Map.of());

        assertNull(taskId);
    }

    @Test
    void submitAsyncTask_DifferentTaskTypes() {
        doNothing().when(rabbitTemplate).convertAndSend(anyString(), anyString(), any(Map.class));

        String taskId1 = aiService.submitAsyncTask("text_analysis", Map.of());
        String taskId2 = aiService.submitAsyncTask("multimodal", Map.of());

        assertNotNull(taskId1);
        assertNotNull(taskId2);
        assertNotEquals(taskId1, taskId2);
    }

    // ==================== 图片分析异常处理 ====================

    @Test
    void analyzeImage_ServiceUnavailable_ReturnsErrorMap() {
        when(aiServiceWebClient.post()).thenThrow(new RuntimeException("Connection refused"));

        Map<String, Object> result = aiService.analyzeImage(
                new byte[]{1, 2, 3}, "test.jpg", "描述");

        assertNotNull(result);
        assertTrue(result.containsKey("error"));
    }

    @Test
    void analyzeImage_HttpError_ReturnsErrorMap() {
        when(aiServiceWebClient.post()).thenThrow(
                WebClientResponseException.create(500, "Internal Server Error",
                        org.springframework.http.HttpHeaders.EMPTY, new byte[0], null));

        Map<String, Object> result = aiService.analyzeImage(
                new byte[]{1, 2, 3}, "test.jpg", null);

        assertNotNull(result);
        assertTrue(result.containsKey("error"));
    }

    // ==================== 文字分析异常处理 ====================

    @Test
    void analyzeText_ServiceUnavailable_ReturnsErrorMap() {
        when(aiServiceWebClient.post()).thenThrow(new RuntimeException("Connection refused"));

        Map<String, Object> result = aiService.analyzeText("测试文字", "jewelry");

        assertNotNull(result);
        assertTrue(result.containsKey("error"));
    }

    // ==================== 多模态分析异常处理 ====================

    @Test
    void analyzeMultimodal_ServiceUnavailable_ReturnsErrorMap() {
        when(aiServiceWebClient.post()).thenThrow(new RuntimeException("Connection refused"));

        Map<String, Object> result = aiService.analyzeMultimodal(
                new byte[]{1, 2}, "描述", "jewelry");

        assertNotNull(result);
        assertTrue(result.containsKey("error"));
    }

    // ==================== 手作人推荐异常处理 ====================

    @Test
    void recommendArtisan_ServiceUnavailable_ReturnsErrorMap() {
        when(aiServiceWebClient.post()).thenThrow(new RuntimeException("Connection refused"));

        Map<String, Object> result = aiService.recommendArtisan(
                "jewelry", "古典", 1000, 5000, 14, 5);

        assertNotNull(result);
        assertTrue(result.containsKey("error"));
    }

    // ==================== 方案推荐异常处理 ====================

    @Test
    void recommendSolution_ServiceUnavailable_ReturnsErrorMap() {
        when(aiServiceWebClient.post()).thenThrow(new RuntimeException("Connection refused"));

        Map<String, Object> result = aiService.recommendSolution(
                "定制银镯", null, "jewelry", 5000, 3);

        assertNotNull(result);
        assertTrue(result.containsKey("error"));
    }

    // ==================== 相似案例异常处理 ====================

    @Test
    void getSimilarCases_ServiceUnavailable_ReturnsErrorMap() {
        when(aiServiceWebClient.get()).thenThrow(new RuntimeException("Connection refused"));

        Map<String, Object> result = aiService.getSimilarCases("case_001", 5);

        assertNotNull(result);
        assertTrue(result.containsKey("error"));
    }

    @Test
    void getSimilarCases_HttpError_ReturnsErrorMap() {
        when(aiServiceWebClient.get()).thenThrow(
                WebClientResponseException.create(404, "Not Found",
                        org.springframework.http.HttpHeaders.EMPTY, new byte[0], null));

        Map<String, Object> result = aiService.getSimilarCases("nonexistent", 5);

        assertNotNull(result);
        assertTrue(result.containsKey("error"));
    }
}

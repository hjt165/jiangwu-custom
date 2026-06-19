package com.jiangwu.controller;

import com.jiangwu.dto.response.ProductResponse;
import com.jiangwu.exception.GlobalExceptionHandler;
import com.jiangwu.service.HistoryService;
import com.jiangwu.utils.CurrentUserUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 浏览历史控制器测试
 */
class HistoryControllerTest {

    private MockMvc mockMvc;
    private HistoryService historyService;
    private CurrentUserUtil currentUserUtil;

    @BeforeEach
    void setUp() {
        historyService = mock(HistoryService.class);
        currentUserUtil = mock(CurrentUserUtil.class);

        HistoryController controller = new HistoryController(historyService, currentUserUtil);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void recordBrowse_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);

        mockMvc.perform(post("/history/record")
                        .header("Authorization", "Bearer test_token")
                        .contentType("application/json")
                        .content("{\"productId\": 1}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void getHistoryList_Success() throws Exception {
        ProductResponse product = new ProductResponse();
        product.setId("1");
        product.setTitle("浏览过的商品");
        product.setPrice(299.00);

        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(historyService.getHistoryList(anyLong()))
                .thenReturn(List.of(product));

        mockMvc.perform(get("/history/list")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void getHistoryList_Empty() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(historyService.getHistoryList(anyLong()))
                .thenReturn(List.of());

        mockMvc.perform(get("/history/list")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void clearHistory_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);

        mockMvc.perform(delete("/history/clear")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }
}

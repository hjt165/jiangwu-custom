package com.jiangwu.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jiangwu.dto.request.CreateOrderRequest;
import com.jiangwu.dto.response.OrderResponse;
import com.jiangwu.exception.GlobalExceptionHandler;
import com.jiangwu.service.OrderService;
import com.jiangwu.utils.CurrentUserUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 订单控制器测试
 */
class OrderControllerTest {

    private MockMvc mockMvc;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private OrderService orderService;
    private CurrentUserUtil currentUserUtil;
    private OrderResponse orderResponse;

    @BeforeEach
    void setUp() {
        orderService = mock(OrderService.class);
        currentUserUtil = mock(CurrentUserUtil.class);

        OrderController controller = new OrderController(orderService, currentUserUtil);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();

        orderResponse = new OrderResponse();
        orderResponse.setId("1");
        orderResponse.setOrderNo("JW20260616001");
        orderResponse.setUserId("1");
        orderResponse.setStatus("待支付");
        orderResponse.setTotalAmount(599.00);
        orderResponse.setCreatedAt(LocalDateTime.now());
    }

    @Test
    void createOrder_Success() throws Exception {
        CreateOrderRequest request = new CreateOrderRequest();
        request.setProductId(1L);
        request.setSpecialRequests("定制需求描述");

        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(orderService.createOrder(anyLong(), any(CreateOrderRequest.class))).thenReturn(orderResponse);

        mockMvc.perform(post("/order/create")
                        .header("Authorization", "Bearer test_token")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.orderNo").value("JW20260616001"));
    }

    @Test
    void getOrderList_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(orderService.getOrderList(anyLong(), any())).thenReturn(List.of(orderResponse));

        mockMvc.perform(get("/order/list")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data[0].orderNo").value("JW20260616001"));
    }

    @Test
    void getOrderList_WithStatus() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(orderService.getOrderList(anyLong(), anyString())).thenReturn(List.of(orderResponse));

        mockMvc.perform(get("/order/list")
                        .header("Authorization", "Bearer test_token")
                        .param("status", "PENDING_PAYMENT"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void getOrderDetail_Success() throws Exception {
        when(orderService.getOrderDetail(anyLong())).thenReturn(orderResponse);

        mockMvc.perform(get("/order/1")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.orderNo").value("JW20260616001"));
    }

    @Test
    void getOrderDetail_NotFound() throws Exception {
        when(orderService.getOrderDetail(anyLong()))
                .thenThrow(new RuntimeException("订单不存在"));

        mockMvc.perform(get("/order/999")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.code").value(500));
    }

    @Test
    void cancelOrder_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);

        mockMvc.perform(put("/order/cancel")
                        .header("Authorization", "Bearer test_token")
                        .param("orderId", "1")
                        .param("reason", "不想要了"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void cancelOrder_NotAllowed() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        doThrow(new RuntimeException("当前订单状态不允许取消"))
                .when(orderService).cancelOrder(anyLong(), anyLong(), anyString());

        mockMvc.perform(put("/order/cancel")
                        .header("Authorization", "Bearer test_token")
                        .param("orderId", "1")
                        .param("reason", "不想要了"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.code").value(500));
    }

    @Test
    void submitReview_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);

        mockMvc.perform(post("/order/review")
                        .header("Authorization", "Bearer test_token")
                        .param("orderId", "1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"rating\": 5, \"content\": \"非常好的手作人！\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }
}

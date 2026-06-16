package com.jiangwu.service;

import com.jiangwu.dto.request.CreateOrderRequest;
import com.jiangwu.dto.response.OrderResponse;
import com.jiangwu.entity.Order;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.repository.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    @Mock
    private OrderStageRepository orderStageRepository;

    @Mock
    private CustomizationRepository customizationRepository;

    @Mock
    private ReviewRepository reviewRepository;

    @Mock
    private ProductRepository productRepository;

    @Mock
    private ArtisanRepository artisanRepository;

    @Mock
    private AiService aiService;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private OrderService orderService;

    private Order testOrder;

    @BeforeEach
    void setUp() {
        testOrder = new Order();
        testOrder.setId(1L);
        testOrder.setOrderNo("JW20260616001");
        testOrder.setUserId(1L);
        testOrder.setArtisanId(1L);
        testOrder.setProductId(1L);
        testOrder.setStatus(OrderStatus.PENDING_PAYMENT);
        testOrder.setTotalAmount(new BigDecimal("599.00"));
        testOrder.setPaidAmount(BigDecimal.ZERO);
        testOrder.setDepositAmount(BigDecimal.ZERO);
        testOrder.setCurrentStage(0);
        testOrder.setCreatedAt(LocalDateTime.now());
    }

    @Test
    void cancelOrder_Success() {
        testOrder.setStatus(OrderStatus.PENDING_PAYMENT);
        when(orderRepository.findById(anyLong())).thenReturn(testOrder);
        when(orderRepository.updateCancelled(anyLong(), any(OrderStatus.class), any(LocalDateTime.class), anyString())).thenReturn(1);

        orderService.cancelOrder(1L, 1L, "不想要了");

        verify(orderRepository, times(1)).updateCancelled(anyLong(), any(OrderStatus.class), any(LocalDateTime.class), anyString());
    }

    @Test
    void cancelOrder_NotPendingPayment_ThrowsException() {
        testOrder.setStatus(OrderStatus.PRODUCING);
        when(orderRepository.findById(anyLong())).thenReturn(testOrder);

        assertThrows(BusinessException.class, () -> orderService.cancelOrder(1L, 1L, "不想要了"));
        verify(orderRepository, never()).updateCancelled(anyLong(), any(OrderStatus.class), any(LocalDateTime.class), anyString());
    }

    @Test
    void cancelOrder_OrderNotFound_ThrowsException() {
        when(orderRepository.findById(anyLong())).thenReturn(null);

        assertThrows(BusinessException.class, () -> orderService.cancelOrder(1L, 1L, "不想要了"));
    }

    @Test
    void getOrderList_EmptyList() {
        when(orderRepository.findByUserId(anyLong())).thenReturn(List.of());

        List<OrderResponse> responses = orderService.getOrderList(1L, null);

        assertNotNull(responses);
        assertTrue(responses.isEmpty());
    }
}

package com.jiangwu.service;

import com.jiangwu.dto.request.CreateOrderRequest;
import com.jiangwu.dto.response.OrderResponse;
import com.jiangwu.entity.Customization;
import com.jiangwu.entity.Order;
import com.jiangwu.entity.OrderStage;
import com.jiangwu.entity.Product;
import com.jiangwu.entity.Artisan;
import com.jiangwu.entity.Review;
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

    @Mock
    private WorkflowService workflowService;

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

    // ========== 订单号生成测试 ==========

    @Test
    void createOrder_GeneratesUniqueOrderNo() {
        CreateOrderRequest request = new CreateOrderRequest();
        request.setArtisanId(1L);
        request.setProductId(1L);

        doAnswer(invocation -> {
            Order order = invocation.getArgument(0);
            order.setId(1L);
            return 1;
        }).when(orderRepository).insert(any(Order.class));
        when(customizationRepository.insert(any(Customization.class))).thenReturn(1);
        when(orderStageRepository.insert(any(OrderStage.class))).thenReturn(1);
        when(orderRepository.findById(anyLong())).thenReturn(testOrder);
        when(orderStageRepository.findByOrderId(anyLong())).thenReturn(List.of());
        when(customizationRepository.findByOrderIds(anyList())).thenReturn(List.of());
        when(productRepository.findById(anyLong())).thenReturn(null);
        when(artisanRepository.findById(anyLong())).thenReturn(null);
        when(aiService.recommendSolution(anyString(), any(), anyString(), anyDouble(), anyInt())).thenReturn(null);

        OrderResponse response = orderService.createOrder(1L, request);

        assertNotNull(response);
        verify(orderRepository, times(1)).insert(any(Order.class));
    }

    // ========== 订单列表测试 ==========

    @Test
    void getOrderList_EmptyList() {
        when(orderRepository.findByUserId(anyLong())).thenReturn(List.of());

        List<OrderResponse> responses = orderService.getOrderList(1L, null);

        assertNotNull(responses);
        assertTrue(responses.isEmpty());
    }

    @Test
    void getOrderList_WithStatusFilter() {
        when(orderRepository.findByUserIdAndStatus(anyLong(), any(OrderStatus.class))).thenReturn(List.of(testOrder));
        when(orderStageRepository.findByOrderIds(anyList())).thenReturn(List.of());
        when(customizationRepository.findByOrderIds(anyList())).thenReturn(List.of());
        when(productRepository.findById(anyLong())).thenReturn(null);
        when(artisanRepository.findById(anyLong())).thenReturn(null);

        List<OrderResponse> responses = orderService.getOrderList(1L, "PENDING_PAYMENT");

        assertNotNull(responses);
        assertEquals(1, responses.size());
    }

    // ========== 订单详情权限测试 ==========

    @Test
    void getOrderDetail_WithUserId_Success() {
        when(orderRepository.findById(anyLong())).thenReturn(testOrder);
        when(orderStageRepository.findByOrderId(anyLong())).thenReturn(List.of());

        OrderResponse response = orderService.getOrderDetail(1L, 1L);

        assertNotNull(response);
    }

    @Test
    void getOrderDetail_WithUserId_Forbidden() {
        when(orderRepository.findById(anyLong())).thenReturn(testOrder);

        assertThrows(BusinessException.class, () -> orderService.getOrderDetail(1L, 2L));
    }

    // ========== 取消订单测试 ==========

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
    void cancelOrder_Forbidden_ThrowsException() {
        testOrder.setStatus(OrderStatus.PENDING_PAYMENT);
        when(orderRepository.findById(anyLong())).thenReturn(testOrder);

        assertThrows(BusinessException.class, () -> orderService.cancelOrder(1L, 2L, "不想要了"));
    }

    @Test
    void cancelOrder_OrderNotFound_ThrowsException() {
        when(orderRepository.findById(anyLong())).thenReturn(null);

        assertThrows(BusinessException.class, () -> orderService.cancelOrder(1L, 1L, "不想要了"));
    }

    // ========== 阶段确认测试 ==========

    @Test
    void confirmStage_Forbidden_ThrowsException() {
        when(orderRepository.findById(anyLong())).thenReturn(testOrder);

        assertThrows(BusinessException.class, () -> orderService.confirmStage(1L, 1L, List.of(), "note", 2L));
    }

    // ========== 评价测试 ==========

    @Test
    void submitReview_Forbidden_ThrowsException() {
        when(orderRepository.findById(anyLong())).thenReturn(testOrder);

        assertThrows(BusinessException.class, () ->
                orderService.submitReview(1L, 2L, 5, "很好", List.of(), List.of(), false));
    }

    @Test
    void submitReview_OrderNotCompleted_ThrowsException() {
        testOrder.setStatus(OrderStatus.PRODUCING);
        when(orderRepository.findById(anyLong())).thenReturn(testOrder);

        assertThrows(BusinessException.class, () ->
                orderService.submitReview(1L, 1L, 5, "很好", List.of(), List.of(), false));
    }

    @Test
    void submitReview_AlreadyReviewed_ThrowsException() {
        testOrder.setStatus(OrderStatus.COMPLETED);
        when(orderRepository.findById(anyLong())).thenReturn(testOrder);
        when(reviewRepository.findByOrderId(anyLong())).thenReturn(new Review());

        assertThrows(BusinessException.class, () ->
                orderService.submitReview(1L, 1L, 5, "很好", List.of(), List.of(), false));
    }
}

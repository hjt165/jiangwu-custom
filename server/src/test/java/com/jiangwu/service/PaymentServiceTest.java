package com.jiangwu.service;

import com.jiangwu.entity.Order;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.repository.OrderRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PaymentServiceTest {

    @Mock private OrderRepository orderRepository;
    @InjectMocks private PaymentService paymentService;

    private Order testOrder;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(paymentService, "mockEnabled", true);
        ReflectionTestUtils.setField(paymentService, "appId", "wx_test_app_id");
        ReflectionTestUtils.setField(paymentService, "partnerId", "wx_test_partner_id");

        testOrder = new Order();
        testOrder.setId(1L);
        testOrder.setOrderNo("JW20260616001");
        testOrder.setUserId(1L);
        testOrder.setStatus(OrderStatus.PENDING_PAYMENT);
        testOrder.setTotalAmount(new BigDecimal("599.00"));
        testOrder.setPaidAmount(BigDecimal.ZERO);
    }

    @Test
    void wechatPrepay_MockEnabled_ReturnsMockData() {
        Map<String, Object> result = paymentService.wechatPrepay("JW20260616001", 599.00);
        assertNotNull(result);
        assertNotNull(result.get("appId"));
        assertNotNull(result.get("prepayId"));
        assertEquals("Sign=WXPay", result.get("package"));
        assertNotNull(result.get("nonceStr"));
        assertNotNull(result.get("timestamp"));
        assertNotNull(result.get("sign"));
    }

    @Test
    void handleNotify_MockMode_UpdatesOrderToPaid() {
        when(orderRepository.findByOrderNo("JW20260616001")).thenReturn(testOrder);
        paymentService.handleNotify("JW20260616001", "TX001");
        verify(orderRepository).updatePaid(eq(1L), eq(OrderStatus.PAID), any(LocalDateTime.class), any(BigDecimal.class));
    }

    @Test
    void handleNotify_OrderNotFoundById_FallsBackToNumericId() {
        when(orderRepository.findByOrderNo("123")).thenReturn(null);
        when(orderRepository.findById(123L)).thenReturn(testOrder);
        paymentService.handleNotify("123", "TX001");
        verify(orderRepository).updatePaid(eq(1L), eq(OrderStatus.PAID), any(LocalDateTime.class), any(BigDecimal.class));
    }

    @Test
    void handleNotify_NonNumericOrderId_ThrowsNumberFormatException() {
        // handleNotify 对非数字 orderId 会执行 Long.parseLong 导致 NumberFormatException
        when(orderRepository.findByOrderNo("nonexistent")).thenReturn(null);
        assertThrows(NumberFormatException.class, () -> paymentService.handleNotify("nonexistent", "TX001"));
    }

    @Test
    void handleNotify_NumericOrderNotFound_DoesNotThrow() {
        when(orderRepository.findByOrderNo("999")).thenReturn(null);
        when(orderRepository.findById(999L)).thenReturn(null);
        assertDoesNotThrow(() -> paymentService.handleNotify("999", "TX001"));
    }

    @Test
    void handleNotify_NullOrderId_DoesNothing() {
        paymentService.handleNotify(null, "TX001");
        verify(orderRepository, never()).findByOrderNo(anyString());
    }

    @Test
    void queryStatus_ReturnsDefaultValues() {
        Map<String, Object> result = paymentService.queryStatus("JW20260616001");
        assertFalse((Boolean) result.get("paid"));
        assertEquals(0, result.get("paidAmount"));
        assertEquals("", result.get("paidAt"));
    }

    @Test
    void refund_MockEnabled_ReturnsTrue() {
        boolean result = paymentService.refund("JW20260616001", 599.00, "不想要了");
        assertTrue(result);
    }

    @Test
    void isMockEnabled_ReturnsTrue() {
        assertTrue(paymentService.isMockEnabled());
    }
}

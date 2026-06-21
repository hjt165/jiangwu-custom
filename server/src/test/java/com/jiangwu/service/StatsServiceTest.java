package com.jiangwu.service;

import com.jiangwu.repository.ArtisanRepository;
import com.jiangwu.repository.OrderRepository;
import com.jiangwu.repository.ProductRepository;
import com.jiangwu.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class StatsServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private OrderRepository orderRepository;
    @Mock private ArtisanRepository artisanRepository;
    @Mock private ProductRepository productRepository;
    @InjectMocks private StatsService statsService;

    @Test
    void getDashboard_ReturnsAllStats() {
        when(userRepository.selectCount(null)).thenReturn(100L);
        when(orderRepository.selectCount(null)).thenReturn(50L);
        when(artisanRepository.selectCount(null)).thenReturn(10L);
        when(productRepository.selectCount(null)).thenReturn(30L);
        when(orderRepository.sumCompletedRevenue()).thenReturn(new BigDecimal("15000.00"));
        when(orderRepository.selectList(any())).thenReturn(java.util.List.of());

        Map<String, Object> result = statsService.getDashboard();

        assertNotNull(result);
        assertEquals(100L, result.get("totalUsers"));
        assertEquals(50L, result.get("totalOrders"));
        assertEquals(10L, result.get("totalArtisans"));
        assertEquals(30L, result.get("totalProducts"));
        assertEquals(new BigDecimal("15000.00"), result.get("totalRevenue"));
        assertNotNull(result.get("todoList"));
    }

    @Test
    void getTransactionStats_ReturnsRevenueData() {
        when(orderRepository.sumCompletedRevenue()).thenReturn(new BigDecimal("20000.00"));
        when(orderRepository.sumCompletedRevenueFrom(any())).thenReturn(new BigDecimal("500.00"));
        when(orderRepository.selectCount(any())).thenReturn(50L);

        Map<String, Object> result = statsService.getTransactionStats("2026-01-01", "2026-12-31");

        assertNotNull(result);
        assertEquals(new BigDecimal("20000.00"), result.get("totalAmount"));
        assertEquals(new BigDecimal("500.00"), result.get("todayAmount"));
    }

    @Test
    void getUserStats_ReturnsUserMetrics() {
        when(userRepository.selectCount(any())).thenReturn(100L);
        when(orderRepository.sumCompletedRevenue()).thenReturn(new BigDecimal("10000.00"));
        when(orderRepository.selectCount(any())).thenReturn(50L);

        Map<String, Object> result = statsService.getUserStats("2026-01-01", "2026-12-31");

        assertNotNull(result);
        assertEquals(100L, result.get("totalUsers"));
        assertNotNull(result.get("newUsers"));
        assertNotNull(result.get("activeUsers"));
        assertNotNull(result.get("retentionRate"));
        assertNotNull(result.get("avgOrderAmount"));
    }
}

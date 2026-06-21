package com.jiangwu.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.jiangwu.entity.Order;
import com.jiangwu.entity.User;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.enums.UserRole;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.repository.OrderRepository;
import com.jiangwu.repository.UserRepository;
import com.jiangwu.utils.JWTUtil;
import com.jiangwu.utils.PasswordUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AdminServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private OrderRepository orderRepository;
    @Mock private JWTUtil jwtUtil;
    @InjectMocks private AdminService adminService;

    private User testUser;
    private Order testOrder;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setPhone("13800000000");
        testUser.setPassword(PasswordUtil.encrypt("admin123"));
        testUser.setNickname("管理员");
        testUser.setRole(UserRole.ADMIN);
        testUser.setStatus(1);

        testOrder = new Order();
        testOrder.setId(1L);
        testOrder.setOrderNo("ORD202601010001");
        testOrder.setUserId(100L);
        testOrder.setStatus(OrderStatus.PENDING_PAYMENT);
        testOrder.setTotalAmount(new BigDecimal("3000.00"));
    }

    // ==================== 登录测试 ====================

    @Test
    void login_Success() {
        when(userRepository.findByPhone("13800000000")).thenReturn(testUser);
        when(jwtUtil.generateToken(1L)).thenReturn("mock-jwt-token");

        Map<String, Object> result = adminService.login("13800000000", "admin123");

        assertNotNull(result);
        assertEquals("mock-jwt-token", result.get("token"));
        assertNotNull(result.get("user"));
    }

    @Test
    void login_UserNotFound_ThrowsException() {
        when(userRepository.findByPhone("99999999999")).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> adminService.login("99999999999", "admin123"));
    }

    @Test
    void login_WrongPassword_ThrowsException() {
        when(userRepository.findByPhone("13800000000")).thenReturn(testUser);

        assertThrows(BusinessException.class,
                () -> adminService.login("13800000000", "wrongpassword"));
    }

    @Test
    void login_NonAdminUser_ThrowsForbidden() {
        User normalUser = new User();
        normalUser.setId(2L);
        normalUser.setPhone("13800000001");
        normalUser.setPassword(PasswordUtil.encrypt("user123"));
        normalUser.setRole(UserRole.USER);
        when(userRepository.findByPhone("13800000001")).thenReturn(normalUser);

        assertThrows(BusinessException.class,
                () -> adminService.login("13800000001", "user123"));
    }

    // ==================== 用户管理测试 ====================

    @Test
    void getUserDetail_Success() {
        when(userRepository.findById(1L)).thenReturn(testUser);

        User result = adminService.getUserDetail(1L);

        assertEquals(1L, result.getId());
        assertEquals("管理员", result.getNickname());
    }

    @Test
    void getUserDetail_NotFound_ThrowsException() {
        when(userRepository.findById(999L)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> adminService.getUserDetail(999L));
    }

    @Test
    void updateUserStatus_Success() {
        doReturn(1).when(userRepository).updateStatus(1L, 0);

        assertDoesNotThrow(() -> adminService.updateUserStatus(1L, 0));
        verify(userRepository).updateStatus(1L, 0);
    }

    @Test
    void updateUserCredit_Success() {
        when(userRepository.findById(1L)).thenReturn(testUser);
        doReturn(1).when(userRepository).updateById(any(User.class));

        assertDoesNotThrow(() -> adminService.updateUserCredit(1L, 90));
        assertEquals(90, testUser.getCreditScore());
    }

    // ==================== 订单管理测试 ====================

    @Test
    void getOrderDetail_Success() {
        when(orderRepository.findById(1L)).thenReturn(testOrder);

        Order result = adminService.getOrderDetail(1L);

        assertEquals("ORD202601010001", result.getOrderNo());
    }

    @Test
    void getOrderDetail_NotFound_ThrowsException() {
        when(orderRepository.findById(999L)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> adminService.getOrderDetail(999L));
    }

    // ==================== 争议仲裁测试 ====================

    @Test
    void resolveDispute_SupportUser_CancelsOrder() {
        when(orderRepository.findById(1L)).thenReturn(testOrder);
        doReturn(1).when(orderRepository).updateById(any(Order.class));

        adminService.resolveDispute(1L, "user");

        assertEquals(OrderStatus.CANCELLED, testOrder.getStatus());
        verify(orderRepository).updateById(testOrder);
    }

    @Test
    void resolveDispute_SupportArtisan_RestartProduction() {
        testOrder.setStatus(OrderStatus.DISPUTED);
        when(orderRepository.findById(1L)).thenReturn(testOrder);
        doReturn(1).when(orderRepository).updateById(any(Order.class));

        adminService.resolveDispute(1L, "artisan");

        assertEquals(OrderStatus.PRODUCING, testOrder.getStatus());
    }

    @Test
    void resolveDispute_Default_CompletesOrder() {
        testOrder.setStatus(OrderStatus.DISPUTED);
        when(orderRepository.findById(1L)).thenReturn(testOrder);
        doReturn(1).when(orderRepository).updateById(any(Order.class));

        adminService.resolveDispute(1L, "compromise");

        assertEquals(OrderStatus.COMPLETED, testOrder.getStatus());
    }

    @Test
    void resolveDispute_OrderNotFound_NoException() {
        when(orderRepository.findById(999L)).thenReturn(null);

        assertDoesNotThrow(() -> adminService.resolveDispute(999L, "user"));
    }
}

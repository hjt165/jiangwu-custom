package com.jiangwu.interceptor;

import com.jiangwu.utils.JWTUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.IOException;
import java.io.PrintWriter;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthInterceptorTest {

    @Mock
    private JWTUtil jwtUtil;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private PrintWriter writer;

    @InjectMocks
    private AuthInterceptor authInterceptor;

    @BeforeEach
    void setUp() throws IOException {
        lenient().when(response.getWriter()).thenReturn(writer);
    }

    // ========== Token验证测试 ==========

    @Test
    void preHandle_NoToken_Returns401() throws IOException {
        when(request.getHeader("Authorization")).thenReturn(null);

        boolean result = authInterceptor.preHandle(request, response, new Object());

        assertFalse(result);
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }

    @Test
    void preHandle_InvalidToken_Returns401() throws IOException {
        when(request.getHeader("Authorization")).thenReturn("Bearer invalid_token");
        when(jwtUtil.extractToken("Bearer invalid_token")).thenReturn("invalid_token");
        when(jwtUtil.validateToken("invalid_token")).thenReturn(false);

        boolean result = authInterceptor.preHandle(request, response, new Object());

        assertFalse(result);
        verify(response).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }

    @Test
    void preHandle_ValidToken_SetsUserIdAndRole() {
        when(request.getHeader("Authorization")).thenReturn("Bearer valid_token");
        when(request.getRequestURI()).thenReturn("/order/list");
        when(jwtUtil.extractToken("Bearer valid_token")).thenReturn("valid_token");
        when(jwtUtil.validateToken("valid_token")).thenReturn(true);
        when(jwtUtil.parseUserId("valid_token")).thenReturn(1L);
        when(jwtUtil.parseUserRole("valid_token")).thenReturn(0); // 普通用户

        boolean result = authInterceptor.preHandle(request, response, new Object());

        assertTrue(result);
        verify(request).setAttribute(AuthInterceptor.CURRENT_USER_ID, 1L);
        verify(request).setAttribute(AuthInterceptor.CURRENT_USER_ROLE, 0);
    }

    // ========== 管理员权限测试 ==========

    @Test
    void preHandle_AdminEndpoint_NonAdmin_Returns403() throws IOException {
        when(request.getHeader("Authorization")).thenReturn("Bearer user_token");
        when(request.getRequestURI()).thenReturn("/admin/users");
        when(jwtUtil.extractToken("Bearer user_token")).thenReturn("user_token");
        when(jwtUtil.validateToken("user_token")).thenReturn(true);
        when(jwtUtil.parseUserId("user_token")).thenReturn(1L);
        when(jwtUtil.parseUserRole("user_token")).thenReturn(0); // 普通用户

        boolean result = authInterceptor.preHandle(request, response, new Object());

        assertFalse(result);
        verify(response).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    @Test
    void preHandle_AdminEndpoint_Admin_ReturnsTrue() {
        when(request.getHeader("Authorization")).thenReturn("Bearer admin_token");
        when(request.getRequestURI()).thenReturn("/admin/users");
        when(jwtUtil.extractToken("Bearer admin_token")).thenReturn("admin_token");
        when(jwtUtil.validateToken("admin_token")).thenReturn(true);
        when(jwtUtil.parseUserId("admin_token")).thenReturn(1L);
        when(jwtUtil.parseUserRole("admin_token")).thenReturn(2); // 管理员

        boolean result = authInterceptor.preHandle(request, response, new Object());

        assertTrue(result);
        verify(response, never()).setStatus(anyInt());
    }

    @Test
    void preHandle_NonAdminEndpoint_NonAdmin_ReturnsTrue() {
        when(request.getHeader("Authorization")).thenReturn("Bearer user_token");
        when(request.getRequestURI()).thenReturn("/api/order/list");
        when(jwtUtil.extractToken("Bearer user_token")).thenReturn("user_token");
        when(jwtUtil.validateToken("user_token")).thenReturn(true);
        when(jwtUtil.parseUserId("user_token")).thenReturn(1L);
        when(jwtUtil.parseUserRole("user_token")).thenReturn(0); // 普通用户

        boolean result = authInterceptor.preHandle(request, response, new Object());

        assertTrue(result);
        verify(response, never()).setStatus(anyInt());
    }
}

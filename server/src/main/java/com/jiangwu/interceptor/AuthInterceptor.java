package com.jiangwu.interceptor;

import com.jiangwu.utils.JWTUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * JWT 认证拦截器 + 角色校验
 */
@Component
@RequiredArgsConstructor
public class AuthInterceptor implements HandlerInterceptor {

    private final JWTUtil jwtUtil;

    public static final String CURRENT_USER_ID = "currentUserId";
    public static final String CURRENT_USER_ROLE = "currentUserRole";

    /** 管理员角色码 */
    private static final int ROLE_ADMIN = 2;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String token = jwtUtil.extractToken(request.getHeader("Authorization"));

        if (token == null || !jwtUtil.validateToken(token)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            try {
                response.getWriter().write("{\"code\":401,\"message\":\"未登录或登录已过期\"}");
            } catch (Exception ignored) {
            }
            return false;
        }

        Long userId = jwtUtil.parseUserId(token);
        int roleCode = jwtUtil.parseUserRole(token);
        request.setAttribute(CURRENT_USER_ID, userId);
        request.setAttribute(CURRENT_USER_ROLE, roleCode);

        // 管理员接口权限校验
        String uri = request.getRequestURI();
        if (uri.startsWith("/admin/") && roleCode != ROLE_ADMIN) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("application/json;charset=UTF-8");
            try {
                response.getWriter().write("{\"code\":403,\"message\":\"无管理员权限\"}");
            } catch (Exception ignored) {
            }
            return false;
        }

        return true;
    }
}

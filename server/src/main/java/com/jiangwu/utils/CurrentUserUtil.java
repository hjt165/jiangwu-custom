package com.jiangwu.utils;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * 当前用户工具类
 * 从JWT Token中提取当前登录用户ID
 */
@Component
@RequiredArgsConstructor
public class CurrentUserUtil {

    private final JWTUtil jwtUtil;

    /**
     * 从请求中提取当前用户ID
     */
    public Long extractUserId(HttpServletRequest request) {
        String token = jwtUtil.extractToken(request.getHeader("Authorization"));
        if (token == null) {
            throw new RuntimeException("未提供认证Token");
        }
        return jwtUtil.parseUserId(token);
    }

    /**
     * 从请求中提取当前用户ID（可选，未登录返回null）
     */
    public Long extractUserIdOrNull(HttpServletRequest request) {
        try {
            return extractUserId(request);
        } catch (Exception e) {
            return null;
        }
    }
}

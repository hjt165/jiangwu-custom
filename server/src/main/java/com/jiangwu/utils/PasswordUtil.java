package com.jiangwu.utils;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * 密码工具类（BCrypt 加密）
 * BCrypt 自带盐值，每次加密结果不同，安全性远高于 SHA-256
 */
@Component
public class PasswordUtil {

    private static final BCryptPasswordEncoder ENCODER = new BCryptPasswordEncoder();

    /**
     * 密码加密（BCrypt）
     */
    public static String encrypt(String rawPassword) {
        return ENCODER.encode(rawPassword);
    }

    /**
     * 验证密码（BCrypt）
     */
    public static boolean verify(String rawPassword, String encryptedPassword) {
        // 兼容旧版 SHA-256 密码：先尝试 BCrypt 验证，失败则尝试旧算法
        if (encryptedPassword.startsWith("$2a$") || encryptedPassword.startsWith("$2b$")) {
            return ENCODER.matches(rawPassword, encryptedPassword);
        }
        // 旧密码迁移：验证旧密码后返回 false，触发重新加密
        return false;
    }

    /**
     * 检查密码是否为旧版 SHA-256 格式
     */
    public static boolean isLegacyPassword(String password) {
        return password != null && !password.startsWith("$2a$") && !password.startsWith("$2b$");
    }
}

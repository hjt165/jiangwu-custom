package com.jiangwu.utils;

import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.stereotype.Component;

/**
 * 密码工具类（SHA-256 加密）
 */
@Component
public class PasswordUtil {

    private static final String SALT = "jiangwu_custom_2026";

    /**
     * 密码加密
     */
    public static String encrypt(String rawPassword) {
        return DigestUtils.sha256Hex(SALT + rawPassword + SALT);
    }

    /**
     * 验证密码
     */
    public static boolean verify(String rawPassword, String encryptedPassword) {
        return encrypt(rawPassword).equals(encryptedPassword);
    }
}

package com.jiangwu.dto.response;

import com.jiangwu.entity.User;
import com.jiangwu.enums.UserRole;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户响应 DTO
 */
@Data
public class UserResponse {

    private String id;
    private String phone;
    private String nickname;
    private String avatar;
    private String role;
    private Integer creditScore;
    private String token;
    private LocalDateTime createdAt;

    /**
     * 从 Entity 转换（不含 token）
     */
    public static UserResponse fromEntity(User user) {
        if (user == null) return null;
        UserResponse dto = new UserResponse();
        dto.setId(String.valueOf(user.getId()));
        dto.setPhone(user.getPhone());
        dto.setNickname(user.getNickname());
        dto.setAvatar(user.getAvatar());
        dto.setRole(user.getRole() != null ? user.getRole().getLabel() : "普通用户");
        dto.setCreditScore(user.getCreditScore());
        dto.setCreatedAt(user.getCreatedAt());
        return dto;
    }

    /**
     * 从 Entity 转换（含 token，用于登录/注册）
     */
    public static UserResponse fromEntityWithToken(User user, String token) {
        UserResponse dto = fromEntity(user);
        if (dto != null) {
            dto.setToken(token);
        }
        return dto;
    }
}

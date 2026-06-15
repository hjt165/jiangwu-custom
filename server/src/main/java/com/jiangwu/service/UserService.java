package com.jiangwu.service;

import com.jiangwu.dto.request.LoginRequest;
import com.jiangwu.dto.request.RegisterRequest;
import com.jiangwu.dto.response.UserResponse;
import com.jiangwu.entity.User;
import com.jiangwu.enums.UserRole;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.exception.ErrorCode;
import com.jiangwu.repository.UserRepository;
import com.jiangwu.utils.JWTUtil;
import com.jiangwu.utils.PasswordUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 用户服务
 */
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final JWTUtil jwtUtil;

    /**
     * 用户注册
     */
    public UserResponse register(RegisterRequest request) {
        // 检查手机号是否已注册
        User existing = userRepository.findByPhone(request.getPhone());
        if (existing != null) {
            throw new BusinessException(ErrorCode.USER_PHONE_EXISTS);
        }

        // 创建用户
        User user = new User();
        user.setPhone(request.getPhone());
        user.setPassword(PasswordUtil.encrypt(request.getPassword()));
        user.setNickname(request.getNickname() != null ? request.getNickname() : "用户" + request.getPhone().substring(7));
        user.setRole(UserRole.USER);
        user.setCreditScore(100);
        user.setStatus(1);
        userRepository.insert(user);

        // 生成 token
        String token = jwtUtil.generateToken(user.getId());
        return UserResponse.fromEntityWithToken(user, token);
    }

    /**
     * 用户登录
     */
    public UserResponse login(LoginRequest request) {
        User user = userRepository.findByPhone(request.getPhone());
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }

        // 验证密码
        if (!PasswordUtil.verify(request.getPassword(), user.getPassword())) {
            throw new BusinessException(ErrorCode.USER_PASSWORD_ERROR);
        }

        // 检查用户状态
        if (user.getStatus() == 0) {
            throw new BusinessException(ErrorCode.USER_DISABLED);
        }

        // 更新登录时间
        userRepository.updateLoginTime(user.getId(), LocalDateTime.now());

        // 生成 token
        String token = jwtUtil.generateToken(user.getId());
        return UserResponse.fromEntityWithToken(user, token);
    }

    /**
     * 获取用户信息
     */
    public UserResponse getUserInfo(Long userId) {
        User user = userRepository.findById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        return UserResponse.fromEntity(user);
    }

    /**
     * 更新用户信息
     */
    public UserResponse updateUser(Long userId, String nickname, String avatar) {
        User user = userRepository.findById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }

        if (nickname != null) {
            user.setNickname(nickname);
        }
        if (avatar != null) {
            user.setAvatar(avatar);
        }
        userRepository.updateById(user);
        return UserResponse.fromEntity(user);
    }
}

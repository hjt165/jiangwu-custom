package com.jiangwu.service;

import com.jiangwu.dto.request.ChangePasswordRequest;
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
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

/**
 * 用户服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final JWTUtil jwtUtil;
    @org.springframework.beans.factory.annotation.Autowired(required = false)
    private RedisTemplate<String, Object> redisTemplate = null;

    /**
     * 发送验证码（带频率限制）
     */
    public void sendCode(String phone) {
        // 频率限制：同号码60秒内不可重复发送
        String rateLimitKey = "code:rate:" + phone;
        if (redisTemplate != null && Boolean.TRUE.equals(redisTemplate.hasKey(rateLimitKey))) {
            throw new BusinessException(ErrorCode.USER_CODE_FREQUENT);
        }

        // 每日上限检查：同号码每日最多10次
        String dailyKey = "code:daily:" + phone;
        if (redisTemplate != null) {
            Object dailyCount = redisTemplate.opsForValue().get(dailyKey);
            if (dailyCount != null && Integer.parseInt(dailyCount.toString()) >= 10) {
                throw new BusinessException(ErrorCode.USER_CODE_FREQUENT);
            }
        }

        // 生成6位验证码
        String code = String.format("%06d", (int) (Math.random() * 1000000));

        // 存储到Redis，有效期5分钟
        String key = "code:" + phone;
        if (redisTemplate != null) {
            redisTemplate.opsForValue().set(key, code, java.time.Duration.ofMinutes(5));
            // 设置60秒频率限制
            redisTemplate.opsForValue().set(rateLimitKey, "1", java.time.Duration.ofSeconds(60));
            // 每日计数+1
            redisTemplate.opsForValue().increment(dailyKey);
            redisTemplate.expire(dailyKey, java.time.Duration.ofDays(1));
        }

        // TODO: 调用真实短信服务发送验证码
        // 生产环境应使用日志框架记录，且不包含验证码明文
        log.info("向手机 {} 发送验证码", phone);
    }

    /**
     * 验证验证码
     */
    public void validateCode(String phone, String code) {
        if (redisTemplate == null) {
            // 测试环境：使用固定验证码 123456
            if (!"123456".equals(code)) {
                throw new BusinessException(ErrorCode.USER_CODE_ERROR);
            }
            return;
        }
        
        String key = "code:" + phone;
        String storedCode = (String) redisTemplate.opsForValue().get(key);
        
        if (storedCode == null) {
            throw new BusinessException(ErrorCode.USER_CODE_EXPIRED);
        }
        
        if (!storedCode.equals(code)) {
            throw new BusinessException(ErrorCode.USER_CODE_ERROR);
        }
        
        // 验证成功后删除验证码
        redisTemplate.delete(key);
    }

    /**
     * 用户注册
     */
    public UserResponse register(RegisterRequest request) {
        // 检查手机号是否已注册
        User existing = userRepository.findByPhone(request.getPhone());
        if (existing != null) {
            throw new BusinessException(ErrorCode.USER_PHONE_EXISTS);
        }

        // 验证验证码
        validateCode(request.getPhone(), request.getCode());

        // 创建用户
        User user = new User();
        user.setPhone(request.getPhone());
        user.setPassword(PasswordUtil.encrypt(request.getPassword()));
        user.setNickname(request.getNickname() != null ? request.getNickname() : "用户" + request.getPhone().substring(7));
        user.setRole(UserRole.USER);
        user.setCreditScore(100);
        user.setStatus(1);
        userRepository.insert(user);

        // 生成 token（包含角色码）
        String token = jwtUtil.generateToken(user.getId(), user.getRole().ordinal());
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

        // 验证密码（支持旧密码自动迁移到 BCrypt）
        if (PasswordUtil.isLegacyPassword(user.getPassword())) {
            // 旧密码：手动验证旧算法，通过后自动升级为 BCrypt
            String oldHash = org.apache.commons.codec.digest.DigestUtils.sha256Hex(
                    "jiangwu_custom_2026" + request.getPassword() + "jiangwu_custom_2026");
            if (!oldHash.equals(user.getPassword())) {
                throw new BusinessException(ErrorCode.USER_PASSWORD_ERROR);
            }
            // 自动迁移到 BCrypt
            user.setPassword(PasswordUtil.encrypt(request.getPassword()));
            userRepository.updateById(user);
        } else if (!PasswordUtil.verify(request.getPassword(), user.getPassword())) {
            throw new BusinessException(ErrorCode.USER_PASSWORD_ERROR);
        }

        // 检查用户状态
        if (user.getStatus() == 0) {
            throw new BusinessException(ErrorCode.USER_DISABLED);
        }

        // 更新登录时间
        userRepository.updateLoginTime(user.getId(), LocalDateTime.now());

        // 生成 token（包含角色码）
        String token = jwtUtil.generateToken(user.getId(), user.getRole().ordinal());
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
     * 修改密码
     */
    public void changePassword(Long userId, ChangePasswordRequest request) {
        User user = userRepository.findById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }

        // 验证旧密码
        if (!PasswordUtil.verify(request.getOldPassword(), user.getPassword())) {
            throw new BusinessException(ErrorCode.USER_PASSWORD_ERROR);
        }

        // 更新为新密码
        user.setPassword(PasswordUtil.encrypt(request.getNewPassword()));
        userRepository.updateById(user);
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

    /**
     * 重置密码
     */
    public void resetPassword(String phone, String code, String newPassword) {
        // 验证验证码
        validateCode(phone, code);

        User user = userRepository.findByPhone(phone);
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }

        // 更新密码
        user.setPassword(PasswordUtil.encrypt(newPassword));
        userRepository.updateById(user);
    }
}

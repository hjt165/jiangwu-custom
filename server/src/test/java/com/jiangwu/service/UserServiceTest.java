package com.jiangwu.service;

import com.jiangwu.dto.request.LoginRequest;
import com.jiangwu.dto.request.RegisterRequest;
import com.jiangwu.dto.response.UserResponse;
import com.jiangwu.entity.User;
import com.jiangwu.enums.UserRole;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.repository.UserRepository;
import com.jiangwu.utils.JWTUtil;
import com.jiangwu.utils.PasswordUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private JWTUtil jwtUtil;

    @Mock
    private RedisTemplate<String, Object> redisTemplate;

    @Mock
    private ValueOperations<String, Object> valueOperations;

    @InjectMocks
    private UserService userService;

    private User testUser;
    private RegisterRequest registerRequest;
    private LoginRequest loginRequest;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setPhone("13800138000");
        testUser.setPassword(PasswordUtil.encrypt("123456"));
        testUser.setNickname("测试用户");
        testUser.setRole(UserRole.USER);
        testUser.setCreditScore(100);
        testUser.setStatus(1);

        registerRequest = new RegisterRequest();
        registerRequest.setPhone("13800138000");
        registerRequest.setPassword("123456");
        registerRequest.setNickname("测试用户");
        registerRequest.setCode("123456");

        loginRequest = new LoginRequest();
        loginRequest.setPhone("13800138000");
        loginRequest.setPassword("123456");
    }

    // ========== 密码加密测试 ==========

    @Test
    void passwordUtil_Encrypt_GeneratesBCryptHash() {
        String rawPassword = "testPassword123";
        String encrypted = PasswordUtil.encrypt(rawPassword);

        assertNotNull(encrypted);
        assertTrue(encrypted.startsWith("$2a$") || encrypted.startsWith("$2b$"));
        assertNotEquals(rawPassword, encrypted);
    }

    @Test
    void passwordUtil_Verify_CorrectPassword_ReturnsTrue() {
        String rawPassword = "testPassword123";
        String encrypted = PasswordUtil.encrypt(rawPassword);

        assertTrue(PasswordUtil.verify(rawPassword, encrypted));
    }

    @Test
    void passwordUtil_Verify_WrongPassword_ReturnsFalse() {
        String rawPassword = "testPassword123";
        String encrypted = PasswordUtil.encrypt(rawPassword);

        assertFalse(PasswordUtil.verify("wrongPassword", encrypted));
    }

    @Test
    void passwordUtil_IsLegacyPassword_SHA256_ReturnsTrue() {
        String sha256Hash = "e10adc3949ba59abbe56e057f20f883e";
        assertTrue(PasswordUtil.isLegacyPassword(sha256Hash));
    }

    @Test
    void passwordUtil_IsLegacyPassword_BCrypt_ReturnsFalse() {
        String bcryptHash = PasswordUtil.encrypt("test");
        assertFalse(PasswordUtil.isLegacyPassword(bcryptHash));
    }

    // ========== 注册测试 ==========

    @Test
    void register_Success() {
        when(userRepository.findByPhone(anyString())).thenReturn(null);
        doAnswer(invocation -> {
            User user = invocation.getArgument(0);
            user.setId(1L);
            return 1;
        }).when(userRepository).insert(any(User.class));
        when(jwtUtil.generateToken(anyLong(), anyInt())).thenReturn("test_token");
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get("code:13800138000")).thenReturn("123456");
        when(redisTemplate.delete("code:13800138000")).thenReturn(true);

        UserResponse response = userService.register(registerRequest);

        assertNotNull(response);
        assertEquals("13800138000", response.getPhone());
        assertEquals("test_token", response.getToken());
        verify(userRepository, times(1)).insert(any(User.class));
    }

    @Test
    void register_DuplicatePhone_ThrowsException() {
        when(userRepository.findByPhone(anyString())).thenReturn(testUser);

        assertThrows(BusinessException.class, () -> userService.register(registerRequest));
        verify(userRepository, never()).insert(any(User.class));
    }

    // ========== 登录测试 ==========

    @Test
    void login_Success_BCryptPassword() {
        when(userRepository.findByPhone(anyString())).thenReturn(testUser);
        when(userRepository.updateLoginTime(anyLong(), any(LocalDateTime.class))).thenReturn(1);
        when(jwtUtil.generateToken(anyLong(), anyInt())).thenReturn("test_token");

        UserResponse response = userService.login(loginRequest);

        assertNotNull(response);
        assertEquals("test_token", response.getToken());
        verify(userRepository, times(1)).updateLoginTime(anyLong(), any(LocalDateTime.class));
    }

    @Test
    void login_Success_LegacyPassword_MigratesToBCrypt() {
        // 模拟旧密码
        User legacyUser = new User();
        legacyUser.setId(1L);
        legacyUser.setPhone("13800138000");
        legacyUser.setPassword(org.apache.commons.codec.digest.DigestUtils.sha256Hex(
                "jiangwu_custom_2026" + "123456" + "jiangwu_custom_2026"));
        legacyUser.setNickname("测试用户");
        legacyUser.setRole(UserRole.USER);
        legacyUser.setStatus(1);

        when(userRepository.findByPhone(anyString())).thenReturn(legacyUser);
        when(userRepository.updateLoginTime(anyLong(), any(LocalDateTime.class))).thenReturn(1);
        when(userRepository.updateById(any(User.class))).thenReturn(1);
        when(jwtUtil.generateToken(anyLong(), anyInt())).thenReturn("test_token");

        UserResponse response = userService.login(loginRequest);

        assertNotNull(response);
        // 验证密码已迁移到 BCrypt
        assertTrue(PasswordUtil.isLegacyPassword(legacyUser.getPassword()) == false ||
                legacyUser.getPassword().startsWith("$2a$"));
        verify(userRepository, times(1)).updateById(any(User.class));
    }

    @Test
    void login_WrongPassword_ThrowsException() {
        User userWithDifferentPassword = new User();
        userWithDifferentPassword.setPassword("different_hashed_password");
        when(userRepository.findByPhone(anyString())).thenReturn(userWithDifferentPassword);

        assertThrows(BusinessException.class, () -> userService.login(loginRequest));
        verify(userRepository, never()).updateLoginTime(anyLong(), any(LocalDateTime.class));
    }

    @Test
    void login_UserDisabled_ThrowsException() {
        testUser.setStatus(0);
        when(userRepository.findByPhone(anyString())).thenReturn(testUser);

        assertThrows(BusinessException.class, () -> userService.login(loginRequest));
    }

    // ========== 用户信息测试 ==========

    @Test
    void getUserInfo_Success() {
        when(userRepository.findById(anyLong())).thenReturn(testUser);

        UserResponse response = userService.getUserInfo(1L);

        assertNotNull(response);
        assertEquals("测试用户", response.getNickname());
    }

    @Test
    void getUserInfo_UserNotFound_ThrowsException() {
        when(userRepository.findById(anyLong())).thenReturn(null);

        assertThrows(BusinessException.class, () -> userService.getUserInfo(1L));
    }

    // ========== 验证码测试 ==========

    @Test
    void validateCode_CorrectCode_ReturnsSuccess() {
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get("code:13800138000")).thenReturn("123456");
        when(redisTemplate.delete("code:13800138000")).thenReturn(true);

        assertDoesNotThrow(() -> userService.validateCode("13800138000", "123456"));
    }

    @Test
    void validateCode_WrongCode_ThrowsException() {
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get("code:13800138000")).thenReturn("654321");

        assertThrows(BusinessException.class, () -> userService.validateCode("13800138000", "123456"));
    }

    @Test
    void validateCode_ExpiredCode_ThrowsException() {
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get("code:13800138000")).thenReturn(null);

        assertThrows(BusinessException.class, () -> userService.validateCode("13800138000", "123456"));
    }
}

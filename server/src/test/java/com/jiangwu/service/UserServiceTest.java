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

        loginRequest = new LoginRequest();
        loginRequest.setPhone("13800138000");
        loginRequest.setPassword("123456");
    }

    @Test
    void register_Success() {
        when(userRepository.findByPhone(anyString())).thenReturn(null);
        when(userRepository.insert(any(User.class))).thenReturn(1);
        when(jwtUtil.generateToken(any())).thenReturn("test_token");

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

    @Test
    void login_Success() {
        when(userRepository.findByPhone(anyString())).thenReturn(testUser);
        when(userRepository.updateLoginTime(anyLong(), any(LocalDateTime.class))).thenReturn(1);
        when(jwtUtil.generateToken(any())).thenReturn("test_token");

        UserResponse response = userService.login(loginRequest);

        assertNotNull(response);
        assertEquals("test_token", response.getToken());
        verify(userRepository, times(1)).updateLoginTime(anyLong(), any(LocalDateTime.class));
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
}

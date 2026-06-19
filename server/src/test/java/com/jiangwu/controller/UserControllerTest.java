package com.jiangwu.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jiangwu.dto.request.LoginRequest;
import com.jiangwu.dto.request.RegisterRequest;
import com.jiangwu.dto.response.UserResponse;
import com.jiangwu.exception.GlobalExceptionHandler;
import com.jiangwu.service.UserService;
import com.jiangwu.utils.CurrentUserUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 用户控制器测试
 */
class UserControllerTest {

    private MockMvc mockMvc;
    private final ObjectMapper objectMapper = new ObjectMapper();

    private UserService userService;
    private CurrentUserUtil currentUserUtil;

    private UserResponse userResponse;

    @BeforeEach
    void setUp() {
        userService = mock(UserService.class);
        currentUserUtil = mock(CurrentUserUtil.class);

        UserController controller = new UserController(userService, currentUserUtil);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();

        userResponse = new UserResponse();
        userResponse.setId("1");
        userResponse.setPhone("13800138000");
        userResponse.setNickname("测试用户");
        userResponse.setRole("普通用户");
        userResponse.setToken("test_token");
    }

    @Test
    void register_Success() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setPhone("13800138000");
        request.setPassword("123456");
        request.setCode("123456");
        request.setNickname("测试用户");

        when(userService.register(any(RegisterRequest.class))).thenReturn(userResponse);

        mockMvc.perform(post("/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.phone").value("13800138000"))
                .andExpect(jsonPath("$.data.token").value("test_token"));
    }

    @Test
    void register_DuplicatePhone_ReturnsError() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setPhone("13800138000");
        request.setPassword("123456");
        request.setCode("123456");
        request.setNickname("测试用户");

        when(userService.register(any(RegisterRequest.class)))
                .thenThrow(new RuntimeException("手机号已注册"));

        mockMvc.perform(post("/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.code").value(500));
    }

    @Test
    void login_Success() throws Exception {
        LoginRequest request = new LoginRequest();
        request.setPhone("13800138000");
        request.setPassword("123456");

        when(userService.login(any(LoginRequest.class))).thenReturn(userResponse);

        mockMvc.perform(post("/user/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.token").value("test_token"));
    }

    @Test
    void login_WrongPassword_ReturnsError() throws Exception {
        LoginRequest request = new LoginRequest();
        request.setPhone("13800138000");
        request.setPassword("wrong_password");

        when(userService.login(any(LoginRequest.class)))
                .thenThrow(new RuntimeException("密码错误"));

        mockMvc.perform(post("/user/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.code").value(500));
    }

    @Test
    void getUserInfo_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(userService.getUserInfo(1L)).thenReturn(userResponse);

        mockMvc.perform(get("/user/info")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.nickname").value("测试用户"));
    }

    @Test
    void updateUser_Success() throws Exception {
        UserResponse updatedResponse = new UserResponse();
        updatedResponse.setId("1");
        updatedResponse.setPhone("13800138000");
        updatedResponse.setNickname("新昵称");
        updatedResponse.setRole("普通用户");

        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(userService.updateUser(anyLong(), anyString(), anyString())).thenReturn(updatedResponse);

        mockMvc.perform(put("/user/update")
                        .header("Authorization", "Bearer test_token")
                        .param("nickname", "新昵称"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }
}

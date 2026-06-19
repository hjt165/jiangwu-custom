package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.dto.request.ChangePasswordRequest;
import com.jiangwu.dto.request.LoginRequest;
import com.jiangwu.dto.request.RegisterRequest;
import com.jiangwu.dto.request.ResetPasswordRequest;
import com.jiangwu.dto.request.SendCodeRequest;
import com.jiangwu.dto.request.UpdateUserRequest;
import com.jiangwu.dto.response.UserResponse;
import com.jiangwu.service.UserService;
import com.jiangwu.utils.CurrentUserUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final CurrentUserUtil currentUserUtil;

    /**
     * 发送验证码
     */
    @PostMapping("/send-code")
    public Result<Void> sendCode(@Valid @RequestBody SendCodeRequest request) {
        userService.sendCode(request.getPhone());
        return Result.success(null);
    }

    /**
     * 用户注册
     */
    @PostMapping("/register")
    public Result<UserResponse> register(@Valid @RequestBody RegisterRequest request) {
        UserResponse response = userService.register(request);
        return Result.success(response);
    }

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<UserResponse> login(@Valid @RequestBody LoginRequest request) {
        UserResponse response = userService.login(request);
        return Result.success(response);
    }

    /**
     * 获取当前用户信息
     */
    @GetMapping("/info")
    public Result<UserResponse> getUserInfo(HttpServletRequest request) {
        Long userId = currentUserUtil.extractUserId(request);
        UserResponse response = userService.getUserInfo(userId);
        return Result.success(response);
    }

    /**
     * 更新用户信息
     */
    @PutMapping("/update")
    public Result<UserResponse> updateUser(HttpServletRequest request,
                                          @RequestBody UpdateUserRequest body) {
        Long userId = currentUserUtil.extractUserId(request);
        UserResponse response = userService.updateUser(userId, body.getNickname(), body.getAvatar());
        return Result.success(response);
    }

    /**
     * 修改密码
     */
    @PostMapping("/change-password")
    public Result<Void> changePassword(HttpServletRequest request,
                                        @Valid @RequestBody ChangePasswordRequest passwordRequest) {
        Long userId = currentUserUtil.extractUserId(request);
        userService.changePassword(userId, passwordRequest);
        return Result.success(null);
    }

    /**
     * 重置密码
     */
    @PostMapping("/reset-password")
    public Result<Void> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        userService.resetPassword(request.getPhone(), request.getCode(), request.getNewPassword());
        return Result.success(null);
    }
  }

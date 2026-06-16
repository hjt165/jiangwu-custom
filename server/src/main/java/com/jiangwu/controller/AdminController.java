package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.entity.Order;
import com.jiangwu.entity.User;
import com.jiangwu.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 管理后台控制器
 */
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    /**
     * 管理员登录
     */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String password = body.get("password");
        return Result.success(adminService.login(phone, password));
    }

    /**
     * 获取用户列表
     */
    @GetMapping("/user/list")
    public Result<List<User>> getUserList(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return Result.success(adminService.getUserList(keyword, status, page, size));
    }

    /**
     * 获取用户详情
     */
    @GetMapping("/user/{id}")
    public Result<User> getUserDetail(@PathVariable Long id) {
        return Result.success(adminService.getUserDetail(id));
    }

    /**
     * 更新用户状态
     */
    @PutMapping("/user/{id}/status")
    public Result<Void> updateUserStatus(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Integer status = (Integer) body.get("status");
        adminService.updateUserStatus(id, status);
        return Result.success();
    }

    /**
     * 更新用户信用分
     */
    @PutMapping("/user/{id}/credit")
    public Result<Void> updateUserCredit(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Integer creditScore = (Integer) body.get("creditScore");
        adminService.updateUserCredit(id, creditScore);
        return Result.success();
    }

    /**
     * 获取订单列表
     */
    @GetMapping("/order/list")
    public Result<List<Order>> getOrderList(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return Result.success(adminService.getOrderList(status, keyword, page, size));
    }

    /**
     * 获取订单详情
     */
    @GetMapping("/order/{id}")
    public Result<Order> getOrderDetail(@PathVariable Long id) {
        return Result.success(adminService.getOrderDetail(id));
    }

    /**
     * 获取争议订单列表
     */
    @GetMapping("/order/dispute")
    public Result<List<Order>> getDisputeList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return Result.success(adminService.getDisputeList(page, size));
    }

    /**
     * 仲裁争议订单
     */
    @PutMapping("/order/{id}/dispute")
    public Result<Void> resolveDispute(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String resolution = (String) body.get("resolution");
        adminService.resolveDispute(id, resolution);
        return Result.success();
    }
}

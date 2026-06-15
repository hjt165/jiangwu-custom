package com.jiangwu.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.jiangwu.common.Result;
import com.jiangwu.entity.Order;
import com.jiangwu.entity.User;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.repository.OrderRepository;
import com.jiangwu.repository.UserRepository;
import com.jiangwu.utils.JWTUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理后台控制器
 */
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final JWTUtil jwtUtil;

    /**
     * 管理员登录
     */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String password = body.get("password");

        User user = userRepository.findByPhone(phone);
        if (user == null || !user.getPassword().equals(password)) {
            return Result.error(401, "手机号或密码错误");
        }
        if (user.getRole() != 2) {
            return Result.error(403, "无管理员权限");
        }

        String token = jwtUtil.generateToken(user.getId());
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("user", Map.of(
                "id", user.getId(),
                "nickname", user.getNickname(),
                "avatar", user.getAvatar(),
                "role", user.getRole()
        ));
        return Result.success(data);
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
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w
                    .like("nickname", keyword)
                    .or()
                    .like("phone", keyword));
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        wrapper.orderByDesc("created_at");
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<User> users = userRepository.selectList(wrapper);
        return Result.success(users);
    }

    /**
     * 获取用户详情
     */
    @GetMapping("/user/{id}")
    public Result<User> getUserDetail(@PathVariable Long id) {
        User user = userRepository.findById(id);
        if (user == null) {
            return Result.error(404, "用户不存在");
        }
        return Result.success(user);
    }

    /**
     * 更新用户状态
     */
    @PutMapping("/user/{id}/status")
    public Result<Void> updateUserStatus(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Integer status = (Integer) body.get("status");
        userRepository.updateStatus(id, status);
        return Result.success();
    }

    /**
     * 更新用户信用分
     */
    @PutMapping("/user/{id}/credit")
    public Result<Void> updateUserCredit(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Integer creditScore = (Integer) body.get("creditScore");
        User user = userRepository.findById(id);
        if (user != null) {
            user.setCreditScore(creditScore);
            userRepository.updateById(user);
        }
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
        QueryWrapper<Order> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0);
        if (status != null && !status.isEmpty()) {
            wrapper.eq("status", status);
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like("order_no", keyword);
        }
        wrapper.orderByDesc("created_at");
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<Order> orders = orderRepository.selectList(wrapper);
        return Result.success(orders);
    }

    /**
     * 获取订单详情
     */
    @GetMapping("/order/{id}")
    public Result<Order> getOrderDetail(@PathVariable Long id) {
        Order order = orderRepository.findById(id);
        if (order == null) {
            return Result.error(404, "订单不存在");
        }
        return Result.success(order);
    }

    /**
     * 获取争议订单列表
     */
    @GetMapping("/order/dispute")
    public Result<List<Order>> getDisputeList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        QueryWrapper<Order> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0)
                .in("status", List.of("dispute", "cancelled"));
        wrapper.orderByDesc("created_at");
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<Order> orders = orderRepository.selectList(wrapper);
        return Result.success(orders);
    }

    /**
     * 仲裁争议订单
     */
    @PutMapping("/order/{id}/dispute")
    public Result<Void> resolveDispute(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String resolution = (String) body.get("resolution");
        Order order = orderRepository.findById(id);
        if (order != null) {
            order.setStatus(OrderStatus.completed.name());
            orderRepository.updateById(order);
        }
        return Result.success();
    }
}

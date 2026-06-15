package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 统计数据控制器
 */
@RestController
@RequestMapping("/stats")
@RequiredArgsConstructor
public class StatsController {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final ArtisanRepository artisanRepository;
    private final ProductRepository productRepository;

    /**
     * 获取仪表盘概览数据
     */
    @GetMapping("/dashboard")
    public Result<Map<String, Object>> getDashboard() {
        Map<String, Object> data = new HashMap<>();

        // 用户统计
        long totalUsers = userRepository.selectCount(null);
        long todayUsers = userRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.User>()
                        .ge("created_at", LocalDateTime.of(LocalDate.now(), LocalTime.MIN))
                        .eq("deleted", 0)
        );
        data.put("totalUsers", totalUsers);
        data.put("todayUsers", todayUsers);

        // 订单统计
        long totalOrders = orderRepository.selectCount(null);
        long todayOrders = orderRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>()
                        .ge("created_at", LocalDateTime.of(LocalDate.now(), LocalTime.MIN))
                        .eq("deleted", 0)
        );
        data.put("totalOrders", totalOrders);
        data.put("todayOrders", todayOrders);

        // 待审核订单
        long pendingOrders = orderRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>()
                        .eq("status", "pending_payment")
                        .eq("deleted", 0)
        );
        data.put("pendingOrders", pendingOrders);

        // 手作人统计
        long totalArtisans = artisanRepository.selectCount(null);
        data.put("totalArtisans", totalArtisans);

        // 作品统计
        long totalProducts = productRepository.selectCount(null);
        data.put("totalProducts", totalProducts);

        return Result.success(data);
    }

    /**
     * 获取交易统计数据
     */
    @GetMapping("/transaction")
    public Result<Map<String, Object>> getTransactionStats(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        Map<String, Object> data = new HashMap<>();

        // 查询已完成订单的总金额
        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order> wrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        wrapper.eq("status", "completed").eq("deleted", 0);
        java.math.BigDecimal totalAmount = orderRepository.selectList(wrapper).stream()
                .map(com.jiangwu.entity.Order::getTotalAmount)
                .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);
        data.put("totalAmount", totalAmount);

        // 查询今日已完成订单金额
        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order> todayWrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        todayWrapper.eq("status", "completed").eq("deleted", 0)
                .ge("created_at", LocalDateTime.of(LocalDate.now(), LocalTime.MIN));
        java.math.BigDecimal todayAmount = orderRepository.selectList(todayWrapper).stream()
                .map(com.jiangwu.entity.Order::getTotalAmount)
                .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);
        data.put("todayAmount", todayAmount);

        // 订单数量
        long orderCount = orderRepository.selectCount(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>().eq("deleted", 0));
        long completedCount = orderRepository.selectCount(wrapper);
        data.put("orderCount", orderCount);
        data.put("completedCount", completedCount);

        return Result.success(data);
    }

    /**
     * 获取用户行为统计数据
     */
    @GetMapping("/user")
    public Result<Map<String, Object>> getUserStats(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        Map<String, Object> data = new HashMap<>();

        // 新增用户数
        long newUsers = userRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.User>()
                        .ge("created_at", LocalDateTime.of(LocalDate.now().minusDays(30), LocalTime.MIN))
                        .eq("deleted", 0)
        );
        data.put("newUsers", newUsers);

        // 活跃用户数（有登录记录）
        long activeUsers = userRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.User>()
                        .isNotNull("last_login_at")
                        .eq("deleted", 0)
        );
        data.put("activeUsers", activeUsers);

        // 用户总数
        long totalUsers = userRepository.selectCount(null);
        data.put("totalUsers", totalUsers);

        // 留存率（简化计算）
        double retentionRate = totalUsers > 0 ? (double) activeUsers / totalUsers * 100 : 0;
        data.put("retentionRate", Math.round(retentionRate * 10.0) / 10.0);

        // 平均订单金额
        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order> avgWrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        avgWrapper.eq("status", "completed").eq("deleted", 0);
        java.math.BigDecimal totalAmount = orderRepository.selectList(avgWrapper).stream()
                .map(com.jiangwu.entity.Order::getTotalAmount)
                .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);
        long completedOrders = orderRepository.selectCount(avgWrapper);
        double avgOrderAmount = completedOrders > 0 ? totalAmount.doubleValue() / completedOrders : 0;
        data.put("avgOrderAmount", Math.round(avgOrderAmount * 100.0) / 100.0);

        return Result.success(data);
    }
}

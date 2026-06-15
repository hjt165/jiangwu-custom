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

        // 这里简化实现，实际应该根据日期范围查询
        // 交易总额
        data.put("totalAmount", 0);
        data.put("todayAmount", 0);
        data.put("orderCount", 0);
        data.put("completedCount", 0);

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

        // 这里简化实现，实际应该根据日期范围查询
        data.put("newUsers", 0);
        data.put("activeUsers", 0);
        data.put("retentionRate", 0);
        data.put("avgOrderAmount", 0);

        return Result.success(data);
    }
}

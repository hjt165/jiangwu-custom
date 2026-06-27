package com.jiangwu.service;

import com.jiangwu.repository.ArtisanRepository;
import com.jiangwu.repository.OrderRepository;
import com.jiangwu.repository.ProductRepository;
import com.jiangwu.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 统计数据服务（使用 SQL 聚合查询，避免全表加载）
 */
@Service
@RequiredArgsConstructor
public class StatsService {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final ArtisanRepository artisanRepository;
    private final ProductRepository productRepository;

    /**
     * 获取仪表盘概览数据（缓存 30 秒）
     */
    public Map<String, Object> getDashboard() {
        Map<String, Object> data = new HashMap<>();

        // 用户统计
        data.put("totalUsers", userRepository.selectCount(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>()));
        data.put("todayUsers", userRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.User>()
                        .ge("created_at", LocalDateTime.of(LocalDate.now(), LocalTime.MIN))
                        .eq("deleted", 0)
        ));

        // 订单统计
        data.put("totalOrders", orderRepository.selectCount(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>()));
        data.put("todayOrders", orderRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>()
                        .ge("created_at", LocalDateTime.of(LocalDate.now(), LocalTime.MIN))
                        .eq("deleted", 0)
        ));
        data.put("pendingOrders", orderRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>()
                        .eq("status", "pending_payment")
                        .eq("deleted", 0)
        ));

        // 手作人/作品统计
        data.put("totalArtisans", artisanRepository.selectCount(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>()));
        data.put("totalProducts", productRepository.selectCount(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>()));

        // 总交易额（使用 SQL SUM，不再全表加载）
        data.put("totalRevenue", orderRepository.sumCompletedRevenue());

        // 待办事项
        data.put("todoList", orderRepository.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>()
                        .eq("status", "pending_payment")
                        .eq("deleted", 0)
                        .orderByDesc("created_at")
                        .last("LIMIT 5")
        ).stream().map(o -> Map.<String, String>of(
                "type", "待处理订单",
                "content", "订单号: " + o.getOrderNo(),
                "time", o.getCreatedAt() != null ? o.getCreatedAt().toString() : ""
        )).toList());

        return data;
    }

    /**
     * 获取交易统计数据
     */
    public Map<String, Object> getTransactionStats(String startDate, String endDate) {
        Map<String, Object> data = new HashMap<>();

        // 使用 SQL SUM 聚合查询
        data.put("totalAmount", orderRepository.sumCompletedRevenue());
        data.put("todayAmount", orderRepository.sumCompletedRevenueFrom(
                LocalDateTime.of(LocalDate.now(), LocalTime.MIN)));

        // 订单数量
        var completedWrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>()
                .eq("status", "completed").eq("deleted", 0);
        data.put("orderCount", orderRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>()
                        .eq("deleted", 0)));
        data.put("completedCount", orderRepository.selectCount(completedWrapper));

        return data;
    }

    /**
     * 获取用户行为统计数据
     */
    public Map<String, Object> getUserStats(String startDate, String endDate) {
        Map<String, Object> data = new HashMap<>();

        // 新增用户数（近30天）
        long newUsers = userRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.User>()
                        .ge("created_at", LocalDateTime.of(LocalDate.now().minusDays(30), LocalTime.MIN))
                        .eq("deleted", 0)
        );
        data.put("newUsers", newUsers);

        // 活跃用户数
        long activeUsers = userRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.User>()
                        .isNotNull("last_login_at")
                        .eq("deleted", 0)
        );
        data.put("activeUsers", activeUsers);

        // 用户总数
        long totalUsers = userRepository.selectCount(null);
        data.put("totalUsers", totalUsers);

        // 留存率
        double retentionRate = totalUsers > 0 ? (double) activeUsers / totalUsers * 100 : 0;
        data.put("retentionRate", Math.round(retentionRate * 10.0) / 10.0);

        // 平均订单金额（使用 SQL SUM）
        BigDecimal totalAmount = orderRepository.sumCompletedRevenue();
        long completedOrders = orderRepository.selectCount(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>()
                        .eq("status", "completed").eq("deleted", 0));
        double avgOrderAmount = completedOrders > 0
                ? totalAmount.divide(BigDecimal.valueOf(completedOrders), 2, RoundingMode.HALF_UP).doubleValue()
                : 0;
        data.put("avgOrderAmount", avgOrderAmount);

        return data;
    }

    /**
     * 获取7天趋势数据（用于图表展示）
     */
    public Map<String, Object> getTrend() {
        Map<String, Object> data = new HashMap<>();

        // 按状态统计订单数
        var statusWrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>()
                .eq("deleted", 0)
                .select("status", "COUNT(*) as count")
                .groupBy("status");
        data.put("statusDistribution", orderRepository.selectMaps(statusWrapper));

        // 近7天每日订单量
        var dailyWrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>()
                .eq("deleted", 0)
                .ge("created_at", LocalDateTime.of(LocalDate.now().minusDays(6), LocalTime.MIN))
                .select("DATE(created_at) as date", "COUNT(*) as count", "COALESCE(SUM(total_amount), 0) as amount")
                .groupBy("DATE(created_at)")
                .orderByAsc("date");
        data.put("dailyTrend", orderRepository.selectMaps(dailyWrapper));

        return data;
    }
}

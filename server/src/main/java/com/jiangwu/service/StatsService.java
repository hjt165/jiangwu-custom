package com.jiangwu.service;

import com.jiangwu.entity.Order;
import com.jiangwu.repository.ArtisanRepository;
import com.jiangwu.repository.OrderRepository;
import com.jiangwu.repository.ProductRepository;
import com.jiangwu.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 统计数据服务
 */
@Service
@RequiredArgsConstructor
public class StatsService {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final ArtisanRepository artisanRepository;
    private final ProductRepository productRepository;

    /**
     * 获取仪表盘概览数据
     */
    public Map<String, Object> getDashboard() {
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

        // 总交易额（已完成订单）
        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order> revenueWrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        revenueWrapper.eq("status", "completed").eq("deleted", 0);
        BigDecimal totalRevenue = orderRepository.selectList(revenueWrapper).stream()
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        data.put("totalRevenue", totalRevenue);

        // 待办事项（待处理订单）
        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order> todoWrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        todoWrapper.eq("status", "pending_payment").eq("deleted", 0)
                .orderByDesc("created_at");
        todoWrapper.last("LIMIT 5");
        List<Map<String, String>> todoList = orderRepository.selectList(todoWrapper).stream()
                .map(o -> Map.of(
                        "type", "待处理订单",
                        "content", "订单号: " + o.getOrderNo(),
                        "time", o.getCreatedAt() != null ? o.getCreatedAt().toString() : ""
                ))
                .collect(Collectors.toList());
        data.put("todoList", todoList);

        return data;
    }

    /**
     * 获取交易统计数据
     */
    public Map<String, Object> getTransactionStats(String startDate, String endDate) {
        Map<String, Object> data = new HashMap<>();

        // 查询已完成订单的总金额
        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order> wrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        wrapper.eq("status", "completed").eq("deleted", 0);
        BigDecimal totalAmount = orderRepository.selectList(wrapper).stream()
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        data.put("totalAmount", totalAmount);

        // 查询今日已完成订单金额
        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order> todayWrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        todayWrapper.eq("status", "completed").eq("deleted", 0)
                .ge("created_at", LocalDateTime.of(LocalDate.now(), LocalTime.MIN));
        BigDecimal todayAmount = orderRepository.selectList(todayWrapper).stream()
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        data.put("todayAmount", todayAmount);

        // 订单数量
        long orderCount = orderRepository.selectCount(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.jiangwu.entity.Order>().eq("deleted", 0));
        long completedCount = orderRepository.selectCount(wrapper);
        data.put("orderCount", orderCount);
        data.put("completedCount", completedCount);

        return data;
    }

    /**
     * 获取用户行为统计数据
     */
    public Map<String, Object> getUserStats(String startDate, String endDate) {
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
        BigDecimal totalAmount = orderRepository.selectList(avgWrapper).stream()
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        long completedOrders = orderRepository.selectCount(avgWrapper);
        double avgOrderAmount = completedOrders > 0 ? totalAmount.doubleValue() / completedOrders : 0;
        data.put("avgOrderAmount", Math.round(avgOrderAmount * 100.0) / 100.0);

        return data;
    }
}

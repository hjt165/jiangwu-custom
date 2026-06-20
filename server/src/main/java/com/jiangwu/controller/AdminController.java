package com.jiangwu.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.jiangwu.common.Result;
import com.jiangwu.entity.Artisan;
import com.jiangwu.entity.Order;
import com.jiangwu.entity.Product;
import com.jiangwu.entity.User;
import com.jiangwu.enums.ArtisanStatus;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.repository.ArtisanRepository;
import com.jiangwu.repository.OrderRepository;
import com.jiangwu.repository.ProductRepository;
import com.jiangwu.repository.UserRepository;
import com.jiangwu.service.AdminService;
import com.jiangwu.service.StatsService;
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

    private final AdminService adminService;
    private final StatsService statsService;
    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final ArtisanRepository artisanRepository;

    // ==================== 认证 ====================

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String password = body.get("password");
        return Result.success(adminService.login(phone, password));
    }

    // ==================== 用户管理 ====================

    @GetMapping("/user/list")
    public Result<Map<String, Object>> getUserList(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like("nickname", keyword).or().like("phone", keyword));
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        long total = userRepository.selectCount(wrapper);
        wrapper.orderByDesc("created_at");
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<User> list = userRepository.selectList(wrapper);
        return Result.success(Map.of("data", list, "total", total));
    }

    @GetMapping("/user/{id}")
    public Result<User> getUserDetail(@PathVariable Long id) {
        return Result.success(adminService.getUserDetail(id));
    }

    @PutMapping("/user/{id}/status")
    public Result<Void> updateUserStatus(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Integer status = (Integer) body.get("status");
        adminService.updateUserStatus(id, status);
        return Result.success();
    }

    @PutMapping("/user/{id}/credit")
    public Result<Void> updateUserCredit(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Integer creditScore = (Integer) body.get("creditScore");
        adminService.updateUserCredit(id, creditScore);
        return Result.success();
    }

    // ==================== 订单管理 ====================

    @GetMapping("/order/list")
    public Result<Map<String, Object>> getOrderList(
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
        long total = orderRepository.selectCount(wrapper);
        wrapper.orderByDesc("created_at");
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<Order> list = orderRepository.selectList(wrapper);
        return Result.success(Map.of("data", list, "total", total));
    }

    @GetMapping("/order/{id}")
    public Result<Order> getOrderDetail(@PathVariable Long id) {
        return Result.success(adminService.getOrderDetail(id));
    }

    @GetMapping("/order/dispute")
    public Result<Map<String, Object>> getDisputeList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        QueryWrapper<Order> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0).in("status", List.of("dispute", "cancelled"));
        long total = orderRepository.selectCount(wrapper);
        wrapper.orderByDesc("created_at");
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<Order> list = orderRepository.selectList(wrapper);
        return Result.success(Map.of("data", list, "total", total));
    }

    @PutMapping("/order/{id}/dispute")
    public Result<Void> resolveDispute(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String resolution = (String) body.get("resolution");
        adminService.resolveDispute(id, resolution);
        return Result.success();
    }

    @PutMapping("/order/{id}/cancel")
    public Result<Void> cancelOrder(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String reason = (String) body.getOrDefault("reason", "管理员取消");
        Order order = orderRepository.findById(id);
        if (order == null) {
            return Result.error(404, "订单不存在");
        }
        orderRepository.updateCancelled(id, com.jiangwu.enums.OrderStatus.CANCELLED, java.time.LocalDateTime.now(), reason);
        return Result.success();
    }

    // ==================== 作品管理 ====================

    @GetMapping("/product/list")
    public Result<Map<String, Object>> getProductList(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        QueryWrapper<Product> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like("title", keyword);
        }
        long total = productRepository.selectCount(wrapper);
        wrapper.orderByDesc("created_at");
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<Product> list = productRepository.selectList(wrapper);

        // 填充手作人名称
        for (Product p : list) {
            Artisan artisan = artisanRepository.findById(p.getArtisanId());
            if (artisan != null) {
                p.setCraftParams(Map.of("artisanName", artisan.getName()));
            }
        }
        return Result.success(Map.of("data", list, "total", total));
    }

    @GetMapping("/product/{id}")
    public Result<Product> getProductDetail(@PathVariable Long id) {
        Product product = productRepository.findById(id);
        if (product == null) {
            return Result.error(404, "作品不存在");
        }
        return Result.success(product);
    }

    @PutMapping("/product/{id}/audit")
    public Result<Void> auditProduct(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Product product = productRepository.findById(id);
        if (product == null) {
            return Result.error(404, "作品不存在");
        }
        String action = body.get("action");
        if ("pass".equals(action)) {
            product.setReviewStatus(1);
        } else if ("reject".equals(action)) {
            product.setReviewStatus(2);
        }
        productRepository.updateById(product);
        return Result.success();
    }

    // ==================== 手作人管理 ====================

    @GetMapping("/artisan/list")
    public Result<Map<String, Object>> getArtisanList(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        QueryWrapper<Artisan> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like("name", keyword).or().like("specialty", keyword);
        }
        long total = artisanRepository.selectCount(wrapper);
        wrapper.orderByDesc("created_at");
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<Artisan> list = artisanRepository.selectList(wrapper);
        return Result.success(Map.of("data", list, "total", total));
    }

    @GetMapping("/artisan/{id}")
    public Result<Artisan> getArtisanDetail(@PathVariable Long id) {
        Artisan artisan = artisanRepository.findById(id);
        if (artisan == null) {
            return Result.error(404, "手作人不存在");
        }
        return Result.success(artisan);
    }

    @PutMapping("/artisan/{id}/audit")
    public Result<Void> auditArtisan(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Artisan artisan = artisanRepository.findById(id);
        if (artisan == null) {
            return Result.error(404, "手作人不存在");
        }
        String action = body.get("action");
        if ("pass".equals(action)) {
            artisanRepository.updateStatus(id, ArtisanStatus.VERIFIED, java.time.LocalDateTime.now());
        } else if ("reject".equals(action)) {
            artisanRepository.updateStatus(id, ArtisanStatus.REJECTED, null);
        }
        return Result.success();
    }

    // ==================== 数据统计代理 ====================

    @GetMapping("/stats/dashboard")
    public Result<Map<String, Object>> getDashboard() {
        return Result.success(statsService.getDashboard());
    }

    @GetMapping("/stats/transaction")
    public Result<Map<String, Object>> getTransactionStats(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        return Result.success(statsService.getTransactionStats(startDate, endDate));
    }

    @GetMapping("/stats/user")
    public Result<Map<String, Object>> getUserStats(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        return Result.success(statsService.getUserStats(startDate, endDate));
    }

    // ==================== 系统设置 ====================

    private final Map<String, Object> settingsStore = new HashMap<>() {{
        put("siteName", "匠物定制");
        put("servicePhone", "400-123-4567");
        put("announcement", "");
        put("autoConfirmDays", 7);
        put("disputeDays", 7);
        put("orderNotify", true);
        put("disputeNotify", true);
    }};

    @GetMapping("/settings")
    public Result<Map<String, Object>> getSettings() {
        return Result.success(settingsStore);
    }

    @PutMapping("/settings")
    public Result<Void> saveSettings(@RequestBody Map<String, Object> body) {
        settingsStore.putAll(body);
        return Result.success();
    }
}

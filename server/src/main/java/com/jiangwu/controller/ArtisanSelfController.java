package com.jiangwu.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangwu.common.Result;
import com.jiangwu.entity.Artisan;
import com.jiangwu.entity.Order;
import com.jiangwu.entity.Product;
import com.jiangwu.entity.Withdraw;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.repository.ArtisanRepository;
import com.jiangwu.repository.OrderRepository;
import com.jiangwu.repository.ProductRepository;
import com.jiangwu.repository.WithdrawRepository;
import com.jiangwu.utils.CurrentUserUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 手作人自助服务控制器
 * 提供手作人工作台、订单管理、作品管理、收入/提现等接口
 */
@RestController
@RequestMapping("/artisan")
@RequiredArgsConstructor
public class ArtisanSelfController {

    private final ArtisanRepository artisanRepository;
    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final WithdrawRepository withdrawRepository;
    private final CurrentUserUtil currentUserUtil;

    /**
     * 获取当前手作人ID（从JWT token中提取userId → 查artisan表）
     */
    private Artisan resolveArtisan(HttpServletRequest request) {
        Long userId = currentUserUtil.extractUserId(request);
        Artisan artisan = artisanRepository.findByUserId(userId);
        if (artisan == null) {
            throw new com.jiangwu.exception.BusinessException(com.jiangwu.exception.ErrorCode.ARTISAN_NOT_FOUND);
        }
        return artisan;
    }

    // ==================== 工作台 ====================

    /**
     * 获取工作台统计数据
     */
    @GetMapping("/workspace/stats")
    public Result<Map<String, Object>> getWorkspaceStats(HttpServletRequest request) {
        Artisan artisan = resolveArtisan(request);

        long pendingOrders = orderRepository.countPendingOrdersByArtisanId(artisan.getId());
        long todayOrders = orderRepository.countTodayOrdersByArtisanId(artisan.getId());

        // 本月收入：completed状态的订单金额
        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        BigDecimal monthIncome = orderRepository.sumCompletedIncomeByArtisanId(artisan.getId(), monthStart);

        int totalWorks = productRepository.countByArtisanId(artisan.getId());

        Map<String, Object> stats = new HashMap<>();
        stats.put("pendingOrders", pendingOrders);
        stats.put("todayOrders", todayOrders);
        stats.put("monthIncome", monthIncome.doubleValue());
        stats.put("totalWorks", totalWorks);
        return Result.success(stats);
    }

    /**
     * 获取待处理订单列表
     */
    @GetMapping("/orders/pending")
    public Result<List<Order>> getPendingOrders(HttpServletRequest request) {
        Artisan artisan = resolveArtisan(request);
        Page<Order> page = orderRepository.findPendingOrdersByArtisanIdPage(new Page<>(1, 100), artisan.getId());
        return Result.success(page.getRecords());
    }

    // ==================== 订单管理 ====================

    /**
     * 获取手作人订单列表
     */
    @GetMapping("/orders")
    public Result<Map<String, Object>> getOrders(
            HttpServletRequest request,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        Artisan artisan = resolveArtisan(request);
        Page<Order> pageParam = new Page<>(page, pageSize);
        Page<Order> result;
        if (status != null && !status.isEmpty()) {
            OrderStatus orderStatus = OrderStatus.valueOf(status);
            result = orderRepository.findByArtisanIdAndStatusPage(pageParam, artisan.getId(), orderStatus);
        } else {
            result = orderRepository.findByArtisanIdPage(pageParam, artisan.getId());
        }
        return Result.success(Map.of("data", result.getRecords(), "total", result.getTotal(), "pages", result.getPages()));
    }

    /**
     * 接受订单
     */
    @PostMapping("/orders/{id}/accept")
    public Result<Void> acceptOrder(@PathVariable Long id, HttpServletRequest request) {
        Artisan artisan = resolveArtisan(request);
        Order order = orderRepository.findById(id);
        if (order == null || !order.getArtisanId().equals(artisan.getId())) {
            return Result.error(404, "订单不存在");
        }
        if (order.getStatus() != OrderStatus.PAID) {
            return Result.error(400, "订单状态不正确");
        }
        orderRepository.updateStatus(id, OrderStatus.PRODUCING);
        return Result.success();
    }

    /**
     * 拒绝订单
     */
    @PostMapping("/orders/{id}/reject")
    public Result<Void> rejectOrder(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        Artisan artisan = resolveArtisan(request);
        Order order = orderRepository.findById(id);
        if (order == null || !order.getArtisanId().equals(artisan.getId())) {
            return Result.error(404, "订单不存在");
        }
        String reason = (String) body.getOrDefault("reason", "手作人拒绝接单");
        orderRepository.updateCancelled(id, OrderStatus.CANCELLED, LocalDateTime.now(), reason);
        return Result.success();
    }

    /**
     * 提交阶段交付
     */
    @PostMapping("/orders/{id}/stages/{stageId}/deliver")
    public Result<Void> submitStageDelivery(
            @PathVariable Long id,
            @PathVariable String stageId,
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        Artisan artisan = resolveArtisan(request);
        Order order = orderRepository.findById(id);
        if (order == null || !order.getArtisanId().equals(artisan.getId())) {
            return Result.error(404, "订单不存在");
        }
        // 更新订单状态为阶段交付中
        orderRepository.updateStatus(id, OrderStatus.STAGE_DELIVERING);
        int stageNum = Integer.parseInt(stageId);
        orderRepository.updateCurrentStage(id, stageNum);
        return Result.success();
    }

    // ==================== 作品管理 ====================

    /**
     * 获取手作人作品列表
     */
    @GetMapping("/products")
    public Result<Map<String, Object>> getProducts(
            HttpServletRequest request,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        Artisan artisan = resolveArtisan(request);
        Page<Product> pageParam = new Page<>(page, pageSize);
        Page<Product> result = productRepository.findByArtisanIdPage(pageParam, artisan.getId());
        return Result.success(Map.of("data", result.getRecords(), "total", result.getTotal(), "pages", result.getPages()));
    }

    /**
     * 发布新作品
     */
    @PostMapping("/products")
    @CacheEvict(value = "products", allEntries = true)
    public Result<Product> createProduct(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        Artisan artisan = resolveArtisan(request);

        Product product = new Product();
        product.setArtisanId(artisan.getId());
        product.setTitle((String) body.get("title"));
        product.setDescription((String) body.get("description"));
        product.setCoverImage((String) body.get("coverImage"));
        if (body.get("price") != null) {
            product.setPrice(new BigDecimal(body.get("price").toString()));
        }
        if (body.get("originalPrice") != null) {
            product.setOriginalPrice(new BigDecimal(body.get("originalPrice").toString()));
        }
        product.setIsAvailable(true);
        product.setIsFeatured(false);
        product.setViewCount(0);
        product.setLikeCount(0);
        product.setOrderCount(0);
        product.setRating(BigDecimal.ZERO);
        product.setReviewStatus(0);

        productRepository.insert(product);
        return Result.success(product);
    }

    /**
     * 更新作品信息
     */
    @PutMapping("/products/{id}")
    @CacheEvict(value = "products", allEntries = true)
    public Result<Void> updateProduct(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        Artisan artisan = resolveArtisan(request);
        Product product = productRepository.findById(id);
        if (product == null || !product.getArtisanId().equals(artisan.getId())) {
            return Result.error(404, "作品不存在");
        }

        if (body.containsKey("title")) product.setTitle((String) body.get("title"));
        if (body.containsKey("description")) product.setDescription((String) body.get("description"));
        if (body.containsKey("coverImage")) product.setCoverImage((String) body.get("coverImage"));
        if (body.get("price") != null) product.setPrice(new BigDecimal(body.get("price").toString()));

        productRepository.updateById(product);
        return Result.success();
    }

    /**
     * 切换作品上下架状态
     */
    @PutMapping("/products/{id}/toggle-status")
    @CacheEvict(value = "products", allEntries = true)
    public Result<Void> toggleProductStatus(@PathVariable Long id, HttpServletRequest request) {
        Artisan artisan = resolveArtisan(request);
        Product product = productRepository.findById(id);
        if (product == null || !product.getArtisanId().equals(artisan.getId())) {
            return Result.error(404, "作品不存在");
        }

        product.setIsAvailable(!product.getIsAvailable());
        productRepository.updateById(product);
        return Result.success();
    }

    /**
     * 删除作品
     */
    @DeleteMapping("/products/{id}")
    @CacheEvict(value = "products", allEntries = true)
    public Result<Void> deleteProduct(@PathVariable Long id, HttpServletRequest request) {
        Artisan artisan = resolveArtisan(request);
        Product product = productRepository.findById(id);
        if (product == null || !product.getArtisanId().equals(artisan.getId())) {
            return Result.error(404, "作品不存在");
        }

        productRepository.deleteById(id);
        return Result.success();
    }

    // ==================== 收入统计 ====================

    /**
     * 获取收入统计数据
     */
    @GetMapping("/income/stats")
    public Result<Map<String, Object>> getIncomeStats(
            HttpServletRequest request,
            @RequestParam(defaultValue = "month") String period) {
        Artisan artisan = resolveArtisan(request);

        BigDecimal totalIncome = orderRepository.sumTotalIncomeByArtisanId(artisan.getId());

        LocalDateTime periodStart = "month".equals(period)
                ? LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0)
                : LocalDateTime.now().withDayOfYear(1).withHour(0).withMinute(0).withSecond(0);

        BigDecimal periodIncome = orderRepository.sumCompletedIncomeByArtisanId(artisan.getId(), periodStart);
        BigDecimal pendingIncome = orderRepository.sumPendingIncomeByArtisanId(artisan.getId());

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalIncome", totalIncome.doubleValue());
        stats.put("monthIncome", periodIncome.doubleValue());
        stats.put("pendingIncome", pendingIncome.doubleValue());
        stats.put("withdrawnIncome", 0.0);
        return Result.success(stats);
    }

    /**
     * 获取收入明细列表
     */
    @GetMapping("/income/records")
    public Result<Map<String, Object>> getIncomeRecords(
            HttpServletRequest request,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        Artisan artisan = resolveArtisan(request);
        Page<Order> pageParam = new Page<>(page, pageSize);
        Page<Order> result = orderRepository.findCompletedOrdersByArtisanIdPage(pageParam, artisan.getId());

        List<Map<String, Object>> records = result.getRecords().stream().map(order -> {
            Map<String, Object> record = new HashMap<>();
            record.put("id", order.getId());
            record.put("orderNo", order.getOrderNo());
            record.put("amount", order.getTotalAmount());
            record.put("completedAt", order.getCompletedAt());
            return record;
        }).collect(Collectors.toList());

        return Result.success(Map.of("data", records, "total", result.getTotal(), "pages", result.getPages()));
    }

    /**
     * 获取提现记录
     */
    @GetMapping("/withdraw/records")
    public Result<Map<String, Object>> getWithdrawRecords(
            HttpServletRequest request,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        Artisan artisan = resolveArtisan(request);
        QueryWrapper<Withdraw> wrapper = new QueryWrapper<>();
        wrapper.eq("artisan_id", artisan.getId()).orderByDesc("created_at");
        Page<Withdraw> result = withdrawRepository.selectPage(new Page<>(page, pageSize), wrapper);
        List<Map<String, Object>> records = result.getRecords().stream().map(w -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", w.getId().toString());
            map.put("amount", w.getAmount());
            map.put("status", w.getStatus() == 0 ? "pending" : w.getStatus() == 1 ? "approved" : w.getStatus() == 2 ? "paid" : "rejected");
            map.put("accountType", w.getAccountType());
            map.put("accountInfo", w.getAccountInfo());
            map.put("remark", w.getRemark());
            map.put("createdAt", w.getCreatedAt() != null ? w.getCreatedAt().toString() : "");
            return map;
        }).collect(Collectors.toList());
        return Result.success(Map.of("data", records, "total", result.getTotal(), "pages", result.getPages()));
    }

    /**
     * 申请提现
     */
    @PostMapping("/withdraw")
    public Result<Void> requestWithdraw(
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        Artisan artisan = resolveArtisan(request);

        // 校验参数
        Object amountObj = body.get("amount");
        if (amountObj == null) {
            return Result.error("提现金额不能为空");
        }
        BigDecimal amount = new BigDecimal(amountObj.toString());
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            return Result.error("提现金额必须大于0");
        }

        String accountType = (String) body.getOrDefault("accountType", "alipay");
        String accountInfo = (String) body.getOrDefault("accountInfo", "");
        if (accountInfo.isEmpty()) {
            return Result.error("提现账号不能为空");
        }

        // 检查是否有待处理的提现申请
        QueryWrapper<Withdraw> pendingWrapper = new QueryWrapper<>();
        pendingWrapper.eq("artisan_id", artisan.getId()).eq("status", 0);
        Long pendingCount = withdrawRepository.selectCount(pendingWrapper);
        if (pendingCount > 0) {
            return Result.error("您有待处理的提现申请，请等待审核");
        }

        // 创建提现记录
        Withdraw withdraw = new Withdraw();
        withdraw.setArtisanId(artisan.getId());
        withdraw.setAmount(amount);
        withdraw.setAccountType(accountType);
        withdraw.setAccountInfo(accountInfo);
        withdraw.setStatus(0); // 待审核
        withdrawRepository.insert(withdraw);

        return Result.success();
    }
}

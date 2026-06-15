package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.dto.request.CreateOrderRequest;
import com.jiangwu.dto.response.OrderResponse;
import com.jiangwu.service.OrderService;
import com.jiangwu.utils.JWTUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 订单控制器
 */
@RestController
@RequestMapping("/order")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final JWTUtil jwtUtil;

    /**
     * 创建订单
     */
    @PostMapping("/create")
    public Result<OrderResponse> createOrder(HttpServletRequest request,
                                             @Valid @RequestBody CreateOrderRequest body) {
        Long userId = extractUserId(request);
        OrderResponse response = orderService.createOrder(userId, body);
        return Result.success(response);
    }

    /**
     * 获取订单列表
     */
    @GetMapping("/list")
    public Result<List<OrderResponse>> getOrderList(
            HttpServletRequest request,
            @RequestParam(required = false) String status) {
        Long userId = extractUserId(request);
        List<OrderResponse> result = orderService.getOrderList(userId, status);
        return Result.success(result);
    }

    /**
     * 获取订单详情
     */
    @GetMapping("/{id}")
    public Result<OrderResponse> getOrderDetail(@PathVariable Long id) {
        OrderResponse response = orderService.getOrderDetail(id);
        return Result.success(response);
    }

    /**
     * 取消订单
     */
    @PutMapping("/cancel")
    public Result<Void> cancelOrder(HttpServletRequest request,
                                    @RequestParam Long orderId,
                                    @RequestParam(required = false) String reason) {
        Long userId = extractUserId(request);
        orderService.cancelOrder(orderId, userId, reason);
        return Result.success();
    }

    /**
     * 确认阶段交付
     */
    @PutMapping("/stage/confirm")
    public Result<Void> confirmStage(@RequestParam Long orderId,
                                     @RequestParam Long stageId,
                                     @RequestBody Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        List<String> images = (List<String>) body.get("images");
        String note = (String) body.get("note");
        orderService.confirmStage(orderId, stageId, images, note);
        return Result.success();
    }

    /**
     * 提交评价
     */
    @PostMapping("/review")
    public Result<Void> submitReview(HttpServletRequest request,
                                     @RequestParam Long orderId,
                                     @RequestBody Map<String, Object> body) {
        Long userId = extractUserId(request);
        Integer rating = (Integer) body.get("rating");
        String content = (String) body.get("content");
        @SuppressWarnings("unchecked")
        List<String> images = (List<String>) body.get("images");
        @SuppressWarnings("unchecked")
        List<String> tags = (List<String>) body.get("tags");
        Boolean isAnonymous = (Boolean) body.get("isAnonymous");

        orderService.submitReview(orderId, userId, rating, content, images, tags, isAnonymous);
        return Result.success();
    }

    /**
     * 从请求中提取用户ID
     */
    private Long extractUserId(HttpServletRequest request) {
        String token = jwtUtil.extractToken(request.getHeader("Authorization"));
        return jwtUtil.parseUserId(token);
    }
}

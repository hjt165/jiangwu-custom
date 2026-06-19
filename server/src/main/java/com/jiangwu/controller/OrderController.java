package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.dto.request.CreateOrderRequest;
import com.jiangwu.dto.response.OrderResponse;
import com.jiangwu.service.OrderService;
import com.jiangwu.utils.CurrentUserUtil;
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
    private final CurrentUserUtil currentUserUtil;

    /**
     * 创建订单
     */
    @PostMapping("/create")
    public Result<OrderResponse> createOrder(HttpServletRequest request,
                                             @Valid @RequestBody CreateOrderRequest body) {
        Long userId = currentUserUtil.extractUserId(request);
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
        Long userId = currentUserUtil.extractUserId(request);
        List<OrderResponse> result = orderService.getOrderList(userId, status);
        return Result.success(result);
    }

    /**
     * 获取订单详情（校验用户权限）
     */
    @GetMapping("/{id}")
    public Result<OrderResponse> getOrderDetail(HttpServletRequest request, @PathVariable Long id) {
        Long userId = currentUserUtil.extractUserId(request);
        OrderResponse response = orderService.getOrderDetail(id, userId);
        return Result.success(response);
    }

    /**
     * 取消订单
     */
    @PutMapping("/cancel")
    public Result<Void> cancelOrder(HttpServletRequest request,
                                    @RequestParam Long orderId,
                                    @RequestParam(required = false) String reason) {
        Long userId = currentUserUtil.extractUserId(request);
        orderService.cancelOrder(orderId, userId, reason);
        return Result.success();
    }

    /**
     * 确认阶段交付（校验用户权限）
     */
    @PutMapping("/stage/confirm")
    public Result<Void> confirmStage(HttpServletRequest request,
                                     @RequestParam Long orderId,
                                     @RequestParam Long stageId,
                                     @RequestBody Map<String, Object> body) {
        Long userId = currentUserUtil.extractUserId(request);
        @SuppressWarnings("unchecked")
        List<String> images = (List<String>) body.get("images");
        String note = (String) body.get("note");
        orderService.confirmStage(orderId, stageId, images, note, userId);
        return Result.success();
    }

    /**
     * 提交评价
     */
    @PostMapping("/review")
    public Result<Void> submitReview(HttpServletRequest request,
                                     @RequestParam Long orderId,
                                     @RequestBody Map<String, Object> body) {
        Long userId = currentUserUtil.extractUserId(request);
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
}

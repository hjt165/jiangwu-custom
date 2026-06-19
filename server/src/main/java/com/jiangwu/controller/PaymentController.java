package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.entity.Order;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.repository.OrderRepository;
import com.jiangwu.utils.CurrentUserUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * 支付控制器
 * 处理微信支付预下单、支付状态查询、退款等
 * 注意：当前为Mock模式，实际接入需要微信商户资质
 */
@Slf4j
@RestController
@RequestMapping("/payment")
@RequiredArgsConstructor
public class PaymentController {

    private final CurrentUserUtil currentUserUtil;
    private final OrderRepository orderRepository;

    @Value("${payment.wechat.app-id:wx_test_app_id}")
    private String appId;

    @Value("${payment.wechat.partner-id:wx_test_partner_id}")
    private String partnerId;

    @Value("${payment.wechat.api-key:wx_test_api_key}")
    private String apiKey;

    @Value("${payment.mock-enabled:true}")
    private boolean mockEnabled;

    /**
     * 微信支付预下单
     * 获取调起微信支付所需的参数
     */
    @PostMapping("/wechat/prepay")
    public Result<Map<String, Object>> wechatPrepay(HttpServletRequest request,
                                                     @RequestBody Map<String, Object> body) {
        Long userId = currentUserUtil.extractUserId(request);
        String orderId = (String) body.get("orderId");
        Double amount = body.get("amount") instanceof Number
                ? ((Number) body.get("amount")).doubleValue()
                : 0.0;
        String description = (String) body.get("description");

        log.info("微信支付预下单: userId={}, orderId={}, amount={}, mock={}", userId, orderId, amount, mockEnabled);

        if (mockEnabled) {
            // Mock模式：返回模拟数据
            Map<String, Object> result = Map.of(
                    "appId", appId,
                    "partnerId", partnerId,
                    "prepayId", "mock_prepay_" + UUID.randomUUID().toString().substring(0, 8),
                    "package", "Sign=WXPay",
                    "nonceStr", UUID.randomUUID().toString().replace("-", ""),
                    "timestamp", System.currentTimeMillis() / 1000,
                    "sign", "mock_sign_" + UUID.randomUUID().toString().substring(0, 8)
            );
            return Result.success(result);
        }

        // 实际接入模式（需要微信商户资质）
        // TODO: 1. 生成随机字符串nonceStr
        // TODO: 2. 调用微信统一下单API获取prepayId
        // TODO: 3. 使用prepayId生成签名返回给客户端
        return Result.error(501, "微信支付未配置，请启用Mock模式或配置商户资质");
    }

    /**
     * 微信支付结果通知
     * 接收微信异步回调
     */
    @PostMapping("/wechat/notify")
    public Result<Void> wechatNotify(@RequestBody Map<String, Object> body) {
        String orderId = (String) body.get("orderId");
        String transactionId = (String) body.get("transactionId");

        log.info("微信支付回调: orderId={}, transactionId={}, mock={}", orderId, transactionId, mockEnabled);

        if (mockEnabled) {
            // Mock模式：模拟支付成功，更新订单状态
            log.info("Mock模式：模拟支付成功，orderId={}", orderId);
            if (orderId != null) {
                Order order = orderRepository.findByOrderNo(orderId);
                if (order == null) {
                    order = orderRepository.findById(Long.parseLong(orderId));
                }
                if (order != null) {
                    orderRepository.updatePaid(order.getId(), OrderStatus.PAID, LocalDateTime.now(), order.getTotalAmount());
                }
            }
            return Result.success();
        }

        // 实际接入模式
        // TODO: 1. 验证微信回调签名
        // TODO: 2. 解密支付结果数据
        // TODO: 3. 更新订单状态为已支付
        // TODO: 4. 返回SUCCESS给微信
        return Result.error(501, "微信支付回调未配置");
    }

    /**
     * 查询订单支付状态
     */
    @GetMapping("/status/{orderId}")
    public Result<Map<String, Object>> queryPaymentStatus(@PathVariable String orderId) {
        log.info("查询支付状态: orderId={}, mock={}", orderId, mockEnabled);

        Map<String, Object> result = new HashMap<>();

        if (mockEnabled) {
            // Mock模式：返回模拟状态
            result.put("paid", false);
            result.put("paidAmount", 0);
            result.put("paidAt", "");
            result.put("mock", true);
            return Result.success(result);
        }

        // 实际接入模式
        // TODO: 查询微信支付订单状态
        result.put("paid", false);
        result.put("paidAmount", 0);
        result.put("paidAt", "");
        result.put("mock", false);
        return Result.success(result);
    }

    /**
     * 申请退款
     */
    @PostMapping("/refund")
    public Result<Void> refund(HttpServletRequest request,
                               @RequestBody Map<String, Object> body) {
        Long userId = currentUserUtil.extractUserId(request);
        String orderId = (String) body.get("orderId");
        Double amount = body.get("amount") instanceof Number
                ? ((Number) body.get("amount")).doubleValue()
                : 0.0;
        String reason = (String) body.get("reason");

        log.info("申请退款: userId={}, orderId={}, amount={}, reason={}, mock={}",
                userId, orderId, amount, reason, mockEnabled);

        if (mockEnabled) {
            // Mock模式：模拟退款成功
            log.info("Mock模式：模拟退款成功，orderId={}, amount={}", orderId, amount);
            return Result.success();
        }

        // 实际接入模式
        // TODO: 1. 查询原支付订单
        // TODO: 2. 调用微信退款接口
        // TODO: 3. 更新订单状态为退款中
        // TODO: 4. 记录退款流水
        return Result.error(501, "微信退款未配置，请启用Mock模式或配置商户资质");
    }
}

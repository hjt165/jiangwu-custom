package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.utils.JWTUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 支付控制器
 * 处理微信支付预下单、支付状态查询、退款等
 */
@Slf4j
@RestController
@RequestMapping("/payment")
@RequiredArgsConstructor
public class PaymentController {

    private final JWTUtil jwtUtil;

    /**
     * 微信支付预下单
     * 获取调起微信支付所需的参数
     */
    @PostMapping("/wechat/prepay")
    public Result<Map<String, Object>> wechatPrepay(HttpServletRequest request,
                                                     @RequestBody Map<String, Object> body) {
        Long userId = extractUserId(request);
        String orderId = (String) body.get("orderId");
        Double amount = body.get("amount") instanceof Number
                ? ((Number) body.get("amount")).doubleValue()
                : 0.0;
        String description = (String) body.get("description");

        log.info("微信支付预下单: userId={}, orderId={}, amount={}", userId, orderId, amount);

        // TODO: 调用微信支付SDK获取预下单参数
        // 实际项目中需要：
        // 1. 生成随机字符串nonceStr
        // 2. 调用微信统一下单API获取prepayId
        // 3. 使用prepayId生成签名返回给客户端
        Map<String, Object> result = Map.of(
                "appId", "wx_test_app_id",
                "partnerId", "wx_test_partner_id",
                "prepayId", "wx_test_prepay_id",
                "package", "Sign=WXPay",
                "nonceStr", "test_nonce_str",
                "timestamp", System.currentTimeMillis() / 1000,
                "sign", "test_sign"
        );

        return Result.success(result);
    }

    /**
     * 微信支付结果通知
     * 接收微信异步回调
     */
    @PostMapping("/wechat/notify")
    public Result<Void> wechatNotify(@RequestBody Map<String, Object> body) {
        String orderId = (String) body.get("orderId");
        String transactionId = (String) body.get("transactionId");

        log.info("微信支付回调: orderId={}, transactionId={}", orderId, transactionId);

        // TODO: 验证签名，更新订单支付状态
        // 实际项目中需要：
        // 1. 验证微信回调签名
        // 2. 解密支付结果数据
        // 3. 更新订单状态为已支付
        // 4. 返回SUCCESS给微信

        return Result.success();
    }

    /**
     * 查询订单支付状态
     */
    @GetMapping("/status/{orderId}")
    public Result<Map<String, Object>> queryPaymentStatus(@PathVariable String orderId) {
        log.info("查询支付状态: orderId={}", orderId);

        // TODO: 查询实际支付状态
        Map<String, Object> result = Map.of(
                "paid", false,
                "paidAmount", 0,
                "paidAt", ""
        );

        return Result.success(result);
    }

    /**
     * 申请退款
     */
    @PostMapping("/refund")
    public Result<Void> refund(HttpServletRequest request,
                               @RequestBody Map<String, Object> body) {
        Long userId = extractUserId(request);
        String orderId = (String) body.get("orderId");
        Double amount = body.get("amount") instanceof Number
                ? ((Number) body.get("amount")).doubleValue()
                : 0.0;
        String reason = (String) body.get("reason");

        log.info("申请退款: userId={}, orderId={}, amount={}, reason={}",
                userId, orderId, amount, reason);

        // TODO: 调用微信退款API
        // 实际项目中需要：
        // 1. 查询原支付订单
        // 2. 调用微信退款接口
        // 3. 更新订单状态为退款中
        // 4. 记录退款流水

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

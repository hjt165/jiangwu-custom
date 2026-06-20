package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.service.PaymentService;
import com.jiangwu.utils.CurrentUserUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

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

    private final PaymentService paymentService;
    private final CurrentUserUtil currentUserUtil;

    /**
     * 微信支付预下单
     */
    @PostMapping("/wechat/prepay")
    public Result<Map<String, Object>> wechatPrepay(HttpServletRequest request,
                                                     @RequestBody Map<String, Object> body) {
        Long userId = currentUserUtil.extractUserId(request);
        String orderId = (String) body.get("orderId");
        Double amount = body.get("amount") instanceof Number
                ? ((Number) body.get("amount")).doubleValue()
                : 0.0;

        Map<String, Object> result = paymentService.wechatPrepay(orderId, amount);
        if (result == null) {
            return Result.error(501, "微信支付未配置，请启用Mock模式或配置商户资质");
        }
        return Result.success(result);
    }

    /**
     * 微信支付结果通知
     */
    @PostMapping("/wechat/notify")
    public Result<Void> wechatNotify(@RequestBody Map<String, Object> body) {
        String orderId = (String) body.get("orderId");
        String transactionId = (String) body.get("transactionId");
        paymentService.handleNotify(orderId, transactionId);
        return Result.success();
    }

    /**
     * 查询订单支付状态
     */
    @GetMapping("/status/{orderId}")
    public Result<Map<String, Object>> queryPaymentStatus(@PathVariable String orderId) {
        return Result.success(paymentService.queryStatus(orderId));
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

        boolean success = paymentService.refund(orderId, amount, reason);
        if (!success) {
            return Result.error(501, "微信退款未配置，请启用Mock模式或配置商户资质");
        }
        return Result.success();
    }
}

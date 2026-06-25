package com.jiangwu.service;

import com.jiangwu.entity.Order;
import com.jiangwu.enums.OrderStatus;
import com.jiangwu.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * 支付服务
 * 处理微信支付Mock逻辑，实际接入需替换为真实微信支付SDK
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final OrderRepository orderRepository;

    @Value("${payment.wechat.app-id:wx_test_app_id}")
    private String appId;

    @Value("${payment.wechat.partner-id:wx_test_partner_id}")
    private String partnerId;

    @Value("${payment.mock-enabled:true}")
    private boolean mockEnabled;

    /**
     * 微信支付预下单（Mock模式）
     */
    public Map<String, Object> wechatPrepay(String orderId, Double amount) {
        log.info("微信支付预下单: orderId={}, amount={}, mock={}", orderId, amount, mockEnabled);

        if (mockEnabled) {
            return Map.of(
                    "appId", appId,
                    "partnerId", partnerId,
                    "prepayId", "mock_prepay_" + UUID.randomUUID().toString().substring(0, 8),
                    "package", "Sign=WXPay",
                    "nonceStr", UUID.randomUUID().toString().replace("-", ""),
                    "timestamp", System.currentTimeMillis() / 1000,
                    "sign", "mock_sign_" + UUID.randomUUID().toString().substring(0, 8)
            );
        }
        return null;
    }

    /**
     * 处理支付回调（Mock模式）
     */
    @Transactional
    public void handleNotify(String orderId, String transactionId) {
        log.info("支付回调: orderId={}, transactionId={}, mock={}", orderId, transactionId, mockEnabled);

        if (mockEnabled && orderId != null) {
            log.info("Mock模式：模拟支付成功，orderId={}", orderId);
            Order order = orderRepository.findByOrderNo(orderId);
            if (order == null) {
                order = orderRepository.findById(Long.parseLong(orderId));
            }
            if (order != null) {
                orderRepository.updatePaid(order.getId(), OrderStatus.PAID, LocalDateTime.now(), order.getTotalAmount());
            }
        }
    }

    /**
     * 查询支付状态
     */
    public Map<String, Object> queryStatus(String orderId) {
        Map<String, Object> result = new HashMap<>();
        result.put("paid", false);
        result.put("paidAmount", 0);
        result.put("paidAt", "");
        result.put("mock", mockEnabled);
        return result;
    }

    /**
     * 申请退款（Mock模式）
     */
    public boolean refund(String orderId, Double amount, String reason) {
        log.info("申请退款: orderId={}, amount={}, reason={}, mock={}", orderId, amount, reason, mockEnabled);

        if (mockEnabled) {
            log.info("Mock模式：模拟退款成功，orderId={}, amount={}", orderId, amount);
            return true;
        }
        return false;
    }

    public boolean isMockEnabled() {
        return mockEnabled;
    }
}

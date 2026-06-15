package com.jiangwu.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

/**
 * 订单状态枚举
 */
@Getter
public enum OrderStatus {

    PENDING_PAYMENT("pending_payment", "待支付"),
    PAID("paid", "已支付"),
    PRODUCING("producing", "制作中"),
    STAGE_DELIVERING("stage_delivering", "阶段交付中"),
    COMPLETED("completed", "已完成"),
    CANCELLED("cancelled", "已取消"),
    REFUNDING("refunding", "退款中"),
    DELAYED("delayed", "延期中"),
    DISPUTED("disputed", "争议中");

    @EnumValue
    private final String code;

    @JsonValue
    private final String label;

    OrderStatus(String code, String label) {
        this.code = code;
        this.label = label;
    }
}

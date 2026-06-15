package com.jiangwu.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

/**
 * 存证类型枚举
 */
@Getter
public enum BlockchainType {

    ORDER_CREATED("order_created", "订单创建"),
    ORDER_SIGNED("order_signed", "订单签订"),
    STAGE_DELIVERED("stage_delivered", "阶段交付"),
    FINAL_DELIVERED("final_delivered", "最终交付"),
    REVIEW_COMPLETED("review_completed", "评价完成");

    @EnumValue
    private final String code;

    @JsonValue
    private final String label;

    BlockchainType(String code, String label) {
        this.code = code;
        this.label = label;
    }
}

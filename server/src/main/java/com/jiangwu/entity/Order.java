package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.jiangwu.enums.OrderStatus;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单实体
 */
@Data
@TableName("t_order")
public class Order {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private String orderNo;

    private Long userId;

    private Long artisanId;

    private Long productId;

    private OrderStatus status;

    private BigDecimal totalAmount;

    private BigDecimal paidAmount;

    private BigDecimal depositAmount;

    private Integer currentStage;

    private String remark;

    private LocalDateTime paidAt;

    private LocalDateTime completedAt;

    private LocalDateTime cancelledAt;

    private String cancelReason;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    private Integer deleted;
}

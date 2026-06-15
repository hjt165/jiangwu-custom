package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 订单阶段实体
 */
@Data
@TableName(value = "t_order_stage", autoResultMap = true)
public class OrderStage {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long orderId;

    private String name;

    private String description;

    private String status;

    private Integer sortOrder;

    private LocalDateTime dueDate;

    private LocalDateTime completedAt;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> deliverImages;

    private String deliverNote;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

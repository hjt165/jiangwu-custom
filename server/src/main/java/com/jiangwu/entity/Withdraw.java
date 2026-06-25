package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 提现记录实体
 */
@Data
@TableName("t_withdraw")
public class Withdraw {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long artisanId;

    private BigDecimal amount;

    private String accountType;

    private String accountInfo;

    private Integer status;

    private String remark;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

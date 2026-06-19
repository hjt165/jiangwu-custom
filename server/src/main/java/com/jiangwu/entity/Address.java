package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 收货地址实体
 */
@Data
@TableName("t_address")
public class Address {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long userId;

    private String name;

    private String phone;

    private String province;

    private String city;

    private String district;

    private String detail;

    private Integer isDefault;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

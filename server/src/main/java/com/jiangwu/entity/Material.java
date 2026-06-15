package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 材质实体
 */
@Data
@TableName("t_material")
public class Material {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private String category;

    private String name;

    private String description;

    private String options;

    private Integer sortOrder;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}

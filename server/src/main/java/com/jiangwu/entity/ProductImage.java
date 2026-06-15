package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 作品图片实体
 */
@Data
@TableName("t_product_image")
public class ProductImage {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long productId;

    private String imageUrl;

    private Integer sortOrder;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}

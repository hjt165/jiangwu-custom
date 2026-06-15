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

    private String description;

    private Integer sortOrder;

    /**
     * 审核状态：0-待审核 1-已通过 2-已拒绝
     */
    private Integer reviewStatus;

    private String reviewRemark;

    private Long reviewerId;

    private LocalDateTime reviewedAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}

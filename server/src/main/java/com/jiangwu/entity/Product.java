package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import com.jiangwu.enums.ProductCategory;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 作品实体
 */
@Data
@TableName(value = "t_product", autoResultMap = true)
public class Product {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long artisanId;

    private String title;

    private String description;

    private ProductCategory category;

    private String coverImage;

    private BigDecimal price;

    private BigDecimal originalPrice;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> craftParams;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> materials;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> tags;

    private Integer viewCount;

    private Integer likeCount;

    private Integer orderCount;

    private BigDecimal rating;

    private Boolean isFeatured;

    private Boolean isAvailable;

    private Integer reviewStatus;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    private Integer deleted;
}

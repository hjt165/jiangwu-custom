package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 定制参数实体
 */
@Data
@TableName(value = "t_customization", autoResultMap = true)
public class Customization {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long orderId;

    private Long productId;

    private String material;

    private String size;

    private String color;

    private String engraving;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> referenceImages;

    private String specialRequests;

    private String aiSuggestion;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> additionalParams;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

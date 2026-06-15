package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 评价实体
 */
@Data
@TableName(value = "t_review", autoResultMap = true)
public class Review {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long orderId;

    private Long userId;

    private Long artisanId;

    private Integer rating;

    private String content;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> images;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> tags;

    private Boolean isAnonymous;

    private String reply;

    private LocalDateTime replyAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    private Integer deleted;
}

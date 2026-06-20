package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 意见反馈实体
 */
@Data
@TableName("t_feedback")
public class Feedback {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long userId;

    private String content;

    private String contact;

    private Integer status;

    private String reply;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

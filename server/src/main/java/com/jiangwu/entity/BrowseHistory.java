package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 浏览历史实体
 */
@Data
@TableName("t_browse_history")
public class BrowseHistory {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long userId;

    private Long productId;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}

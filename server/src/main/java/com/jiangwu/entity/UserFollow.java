package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户关注实体
 */
@Data
@TableName("t_user_follow")
public class UserFollow {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long userId;

    private Long artisanId;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}

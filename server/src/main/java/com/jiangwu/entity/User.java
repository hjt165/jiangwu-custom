package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.jiangwu.enums.UserRole;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户实体
 */
@Data
@TableName("t_user")
public class User {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private String phone;

    private String password;

    private String nickname;

    private String avatar;

    private UserRole role;

    private Integer creditScore;

    private Integer status;

    private LocalDateTime lastLoginAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    private Integer deleted;
}

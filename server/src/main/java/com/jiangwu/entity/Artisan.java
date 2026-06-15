package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import com.jiangwu.enums.ArtisanStatus;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 手作人实体
 */
@Data
@TableName(value = "t_artisan", autoResultMap = true)
public class Artisan {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long userId;

    private String name;

    private String avatar;

    private String bio;

    private String specialty;

    private Integer yearsOfExp;

    private String location;

    private BigDecimal rating;

    private Integer orderCount;

    private Integer fanCount;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> certifications;

    private ArtisanStatus status;

    private LocalDateTime appliedAt;

    private LocalDateTime approvedAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    private Integer deleted;
}

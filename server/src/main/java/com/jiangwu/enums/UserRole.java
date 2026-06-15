package com.jiangwu.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

/**
 * 用户角色枚举
 */
@Getter
public enum UserRole {

    USER(0, "普通用户"),
    ARTISAN(1, "手作人"),
    ADMIN(2, "管理员");

    @EnumValue
    private final int code;

    @JsonValue
    private final String label;

    UserRole(int code, String label) {
        this.code = code;
        this.label = label;
    }
}

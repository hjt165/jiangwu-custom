package com.jiangwu.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

/**
 * 手作人状态枚举
 */
@Getter
public enum ArtisanStatus {

    PENDING(0, "待审核"),
    VERIFIED(1, "已认证"),
    REJECTED(2, "已拒绝"),
    SUSPENDED(3, "已封禁");

    @EnumValue
    @JsonValue
    private final int code;

    private final String label;

    ArtisanStatus(int code, String label) {
        this.code = code;
        this.label = label;
    }
}

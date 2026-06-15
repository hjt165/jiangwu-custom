package com.jiangwu.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

/**
 * 作品分类枚举
 */
@Getter
public enum ProductCategory {

    JEWELRY("jewelry", "首饰"),
    LEATHER("leather", "皮具"),
    CERAMIC("ceramic", "陶瓷"),
    WOODWORK("woodwork", "木艺"),
    PAINTING("painting", "绘画"),
    OTHER("other", "其他");

    @EnumValue
    private final String code;

    @JsonValue
    private final String label;

    ProductCategory(String code, String label) {
        this.code = code;
        this.label = label;
    }
}

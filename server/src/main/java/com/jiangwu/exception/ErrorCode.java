package com.jiangwu.exception;

import lombok.Getter;

/**
 * 错误码枚举
 */
@Getter
public enum ErrorCode {

    // 通用错误
    SUCCESS(200, "操作成功"),
    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未登录或登录已过期"),
    FORBIDDEN(403, "没有操作权限"),
    NOT_FOUND(404, "资源不存在"),
    INTERNAL_ERROR(500, "服务器内部错误"),

    // 用户模块 1xxx
    USER_NOT_FOUND(1001, "用户不存在"),
    USER_PHONE_EXISTS(1002, "手机号已注册"),
    USER_PASSWORD_ERROR(1003, "密码错误"),
    USER_CODE_EXPIRED(1004, "验证码已过期"),
    USER_CODE_ERROR(1005, "验证码错误"),
    USER_DISABLED(1006, "账号已被禁用"),

    // 手作人模块 2xxx
    ARTISAN_NOT_FOUND(2001, "手作人不存在"),
    ARTISAN_APPLICATION_EXISTS(2002, "已提交过申请，请勿重复提交"),
    ARTISAN_NOT_APPROVED(2003, "手作人资质未通过审核"),

    // 作品模块 3xxx
    PRODUCT_NOT_FOUND(3001, "作品不存在"),
    PRODUCT_UNAVAILABLE(3002, "作品已下架"),
    PRODUCT_STOCK_INSUFFICIENT(3003, "库存不足"),

    // 订单模块 4xxx
    ORDER_NOT_FOUND(4001, "订单不存在"),
    ORDER_STATUS_ERROR(4002, "订单状态不允许此操作"),
    ORDER_AMOUNT_ERROR(4003, "订单金额异常"),
    ORDER_STAGE_NOT_FOUND(4004, "订单阶段不存在"),

    // 定制模块 5xxx
    CUSTOMIZATION_NOT_FOUND(5001, "定制参数不存在"),

    // 评价模块 6xxx
    REVIEW_NOT_FOUND(6001, "评价不存在"),
    REVIEW_ALREADY_EXISTS(6002, "已评价过该订单"),

    // 文件模块 7xxx
    FILE_UPLOAD_FAILED(7001, "文件上传失败"),
    FILE_TYPE_NOT_ALLOWED(7002, "文件类型不支持"),
    FILE_SIZE_EXCEEDED(7003, "文件大小超出限制"),

    // 收藏模块 8xxx
    FAVORITE_ALREADY_EXISTS(8001, "已收藏该作品"),
    FAVORITE_NOT_FOUND(8002, "收藏记录不存在");

    private final int code;
    private final String message;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }
}

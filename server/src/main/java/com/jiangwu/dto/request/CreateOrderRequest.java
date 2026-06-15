package com.jiangwu.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

/**
 * 创建订单请求
 */
@Data
public class CreateOrderRequest {

    @NotNull(message = "手作人ID不能为空")
    private Long artisanId;

    private Long productId;

    private String material;

    private String size;

    private String color;

    private String engraving;

    private List<String> referenceImages;

    private String specialRequests;

    private String remark;
}

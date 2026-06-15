package com.jiangwu.dto.response;

import com.jiangwu.entity.Order;
import com.jiangwu.entity.OrderStage;
import com.jiangwu.enums.OrderStatus;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 订单响应 DTO
 */
@Data
public class OrderResponse {

    private String id;
    private String orderNo;
    private String userId;
    private String artisanId;
    private String status;
    private double totalAmount;
    private double paidAmount;
    private double depositAmount;
    private int currentStage;
    private String remark;

    /** 嵌套的作品信息 */
    private ProductResponse product;

    /** 嵌套的手作人信息 */
    private ArtisanResponse artisan;

    /** 嵌套的定制参数 */
    private CustomizationResponse customization;

    /** 阶段列表 */
    private List<StageResponse> stages;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime paidAt;
    private LocalDateTime completedAt;

    /**
     * 从 Entity 转换（不含嵌套数据）
     */
    public static OrderResponse fromEntity(Order order) {
        if (order == null) return null;
        OrderResponse dto = new OrderResponse();
        dto.setId(String.valueOf(order.getId()));
        dto.setOrderNo(order.getOrderNo());
        dto.setUserId(String.valueOf(order.getUserId()));
        dto.setArtisanId(order.getArtisanId() != null ? String.valueOf(order.getArtisanId()) : null);
        dto.setStatus(order.getStatus() != null ? order.getStatus().getLabel() : "未知");
        dto.setTotalAmount(order.getTotalAmount() != null ? order.getTotalAmount().doubleValue() : 0);
        dto.setPaidAmount(order.getPaidAmount() != null ? order.getPaidAmount().doubleValue() : 0);
        dto.setDepositAmount(order.getDepositAmount() != null ? order.getDepositAmount().doubleValue() : 0);
        dto.setCurrentStage(order.getCurrentStage() != null ? order.getCurrentStage() : 0);
        dto.setRemark(order.getRemark());
        dto.setCreatedAt(order.getCreatedAt());
        dto.setUpdatedAt(order.getUpdatedAt());
        dto.setPaidAt(order.getPaidAt());
        dto.setCompletedAt(order.getCompletedAt());
        return dto;
    }

    /**
     * 设置阶段列表
     */
    public void setStagesFromEntities(List<OrderStage> stageEntities) {
        if (stageEntities == null) return;
        this.stages = stageEntities.stream()
                .map(StageResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * 阶段响应 DTO
     */
    @Data
    public static class StageResponse {
        private String id;
        private String name;
        private String description;
        private String status;
        private LocalDateTime dueDate;
        private LocalDateTime completedAt;
        private List<String> deliverImages;
        private String deliverNote;

        public static StageResponse fromEntity(OrderStage stage) {
            if (stage == null) return null;
            StageResponse dto = new StageResponse();
            dto.setId(String.valueOf(stage.getId()));
            dto.setName(stage.getName());
            dto.setDescription(stage.getDescription());
            dto.setStatus(stage.getStatus());
            dto.setDueDate(stage.getDueDate());
            dto.setCompletedAt(stage.getCompletedAt());
            dto.setDeliverImages(stage.getDeliverImages());
            dto.setDeliverNote(stage.getDeliverNote());
            return dto;
        }
    }

    /**
     * 手作人响应 DTO（嵌套用）
     */
    @Data
    public static class ArtisanResponse {
        private String id;
        private String name;
        private String avatar;
        private String bio;
        private String specialty;
        private double rating;

        public static ArtisanResponse fromEntity(com.jiangwu.entity.Artisan artisan) {
            if (artisan == null) return null;
            ArtisanResponse dto = new ArtisanResponse();
            dto.setId(String.valueOf(artisan.getId()));
            dto.setName(artisan.getName());
            dto.setAvatar(artisan.getAvatar());
            dto.setBio(artisan.getBio());
            dto.setSpecialty(artisan.getSpecialty());
            dto.setRating(artisan.getRating() != null ? artisan.getRating().doubleValue() : 0);
            return dto;
        }
    }

    /**
     * 定制参数响应 DTO（嵌套用）
     */
    @Data
    public static class CustomizationResponse {
        private String id;
        private String material;
        private String size;
        private String color;
        private String engraving;
        private List<String> referenceImages;
        private String specialRequests;
        private String aiSuggestion;

        public static CustomizationResponse fromEntity(com.jiangwu.entity.Customization c) {
            if (c == null) return null;
            CustomizationResponse dto = new CustomizationResponse();
            dto.setId(String.valueOf(c.getId()));
            dto.setMaterial(c.getMaterial());
            dto.setSize(c.getSize());
            dto.setColor(c.getColor());
            dto.setEngraving(c.getEngraving());
            dto.setReferenceImages(c.getReferenceImages());
            dto.setSpecialRequests(c.getSpecialRequests());
            dto.setAiSuggestion(c.getAiSuggestion());
            return dto;
        }
    }
}

package com.jiangwu.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.jiangwu.entity.Product;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 作品响应 DTO
 * 字段命名与 Flutter Product.fromJson 保持一致
 */
@Data
public class ProductResponse {

    private String id;
    private String artisanId;
    private String title;
    private String description;
    private String category;
    private List<String> images;
    private String coverImage;
    private double price;
    private Double originalPrice;
    private Object craftParams;
    private List<String> materials;
    private List<String> tags;
    private int viewCount;
    private int likeCount;
    private int orderCount;
    private double rating;

    @JsonProperty("isFeatured")
    private boolean isFeatured;

    @JsonProperty("isAvailable")
    private boolean isAvailable;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /**
     * 从 Entity 转换
     */
    public static ProductResponse fromEntity(Product product) {
        if (product == null) return null;
        ProductResponse dto = new ProductResponse();
        dto.setId(String.valueOf(product.getId()));
        dto.setArtisanId(String.valueOf(product.getArtisanId()));
        dto.setTitle(product.getTitle());
        dto.setDescription(product.getDescription());
        dto.setCategory(product.getCategory() != null ? product.getCategory().getCode() : "other");
        dto.setCoverImage(product.getCoverImage());
        dto.setPrice(product.getPrice() != null ? product.getPrice().doubleValue() : 0);
        dto.setOriginalPrice(product.getOriginalPrice() != null ? product.getOriginalPrice().doubleValue() : null);
        dto.setCraftParams(product.getCraftParams());
        dto.setMaterials(product.getMaterials());
        dto.setTags(product.getTags());
        dto.setViewCount(product.getViewCount() != null ? product.getViewCount() : 0);
        dto.setLikeCount(product.getLikeCount() != null ? product.getLikeCount() : 0);
        dto.setOrderCount(product.getOrderCount() != null ? product.getOrderCount() : 0);
        dto.setRating(product.getRating() != null ? product.getRating().doubleValue() : 0);
        dto.setFeatured(Boolean.TRUE.equals(product.getIsFeatured()));
        dto.setAvailable(Boolean.TRUE.equals(product.getIsAvailable()));
        dto.setCreatedAt(product.getCreatedAt());
        dto.setUpdatedAt(product.getUpdatedAt());
        return dto;
    }

    /**
     * 设置图片列表（由 Service 层调用）
     */
    public void setImagesFromUrls(List<String> urls) {
        this.images = urls;
    }
}

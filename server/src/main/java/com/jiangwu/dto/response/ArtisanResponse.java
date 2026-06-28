package com.jiangwu.dto.response;

import com.jiangwu.entity.Artisan;
import com.jiangwu.entity.Product;
import com.jiangwu.repository.ProductRepository;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 手作人响应 DTO
 * 字段命名与 Flutter Artisan.fromJson 保持一致
 */
@Data
public class ArtisanResponse {

    private String id;
    private String userId;
    private String name;
    private String avatar;
    private String description;
    private String specialty;
    private List<String> categories;
    private String status;
    private double rating;
    private int ratingCount;
    private int orderCount;
    private int followerCount;
    private int followingCount;
    private int workCount;
    private List<ProductResponse> works;
    private List<String> certifications;
    private String location;
    private Integer yearsOfExp;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /**
     * 从 Entity 转换（无作品列表，用于列表页）
     */
    public static ArtisanResponse fromEntity(Artisan artisan) {
        return fromEntity(artisan, null);
    }

    /**
     * 从 Entity 转换（含作品列表，用于详情页）
     */
    public static ArtisanResponse fromEntity(Artisan artisan, List<Product> artisanProducts) {
        if (artisan == null) return null;
        ArtisanResponse dto = new ArtisanResponse();
        dto.setId(String.valueOf(artisan.getId()));
        dto.setUserId(String.valueOf(artisan.getUserId()));
        dto.setName(artisan.getName());
        dto.setAvatar(artisan.getAvatar());
        dto.setDescription(artisan.getBio());
        dto.setSpecialty(artisan.getSpecialty());
        dto.setCategories(artisan.getSpecialty() != null
                ? List.of(artisan.getSpecialty()) : Collections.emptyList());
        dto.setStatus(artisan.getStatus() != null ? artisan.getStatus().name().toLowerCase() : "pending");
        dto.setRating(artisan.getRating() != null ? artisan.getRating().doubleValue() : 0);
        dto.setOrderCount(artisan.getOrderCount() != null ? artisan.getOrderCount() : 0);
        dto.setFollowerCount(artisan.getFanCount() != null ? artisan.getFanCount() : 0);
        dto.setFollowingCount(0);
        dto.setCertifications(artisan.getCertifications() != null ? artisan.getCertifications() : new ArrayList<>());
        dto.setLocation(artisan.getLocation());
        dto.setYearsOfExp(artisan.getYearsOfExp());
        dto.setCreatedAt(artisan.getCreatedAt());
        dto.setUpdatedAt(artisan.getUpdatedAt());

        if (artisanProducts != null) {
            dto.setWorks(artisanProducts.stream()
                    .map(ProductResponse::fromEntity)
                    .collect(Collectors.toList()));
            dto.setWorkCount(artisanProducts.size());
        } else {
            dto.setWorks(new ArrayList<>());
            dto.setWorkCount(0);
        }

        return dto;
    }
}

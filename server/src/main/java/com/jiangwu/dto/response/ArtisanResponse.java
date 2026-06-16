package com.jiangwu.dto.response;

import com.jiangwu.entity.Artisan;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 手作人响应 DTO
 */
@Data
public class ArtisanResponse {

    private String id;
    private String userId;
    private String name;
    private String avatar;
    private String bio;
    private String specialty;
    private Integer yearsOfExp;
    private String location;
    private double rating;
    private Integer orderCount;
    private Integer fanCount;
    private List<String> certifications;
    private String status;
    private LocalDateTime createdAt;

    /**
     * 从 Entity 转换
     */
    public static ArtisanResponse fromEntity(Artisan artisan) {
        if (artisan == null) return null;
        ArtisanResponse dto = new ArtisanResponse();
        dto.setId(String.valueOf(artisan.getId()));
        dto.setUserId(String.valueOf(artisan.getUserId()));
        dto.setName(artisan.getName());
        dto.setAvatar(artisan.getAvatar());
        dto.setBio(artisan.getBio());
        dto.setSpecialty(artisan.getSpecialty());
        dto.setYearsOfExp(artisan.getYearsOfExp());
        dto.setLocation(artisan.getLocation());
        dto.setRating(artisan.getRating() != null ? artisan.getRating().doubleValue() : 0);
        dto.setOrderCount(artisan.getOrderCount());
        dto.setFanCount(artisan.getFanCount());
        dto.setCertifications(artisan.getCertifications());
        dto.setStatus(artisan.getStatus() != null ? artisan.getStatus().getLabel() : "未知");
        dto.setCreatedAt(artisan.getCreatedAt());
        return dto;
    }
}

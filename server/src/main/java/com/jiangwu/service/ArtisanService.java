package com.jiangwu.service;

import com.jiangwu.dto.response.OrderResponse;
import com.jiangwu.dto.response.ArtisanResponse;
import com.jiangwu.entity.Artisan;
import com.jiangwu.entity.Product;
import com.jiangwu.enums.ArtisanStatus;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.exception.ErrorCode;
import com.jiangwu.repository.ArtisanRepository;
import com.jiangwu.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 手作人服务
 */
@Service
@RequiredArgsConstructor
public class ArtisanService {

    private final ArtisanRepository artisanRepository;
    private final ProductRepository productRepository;

    /**
     * 获取手作人列表（缓存 5 分钟）
     */
    public List<ArtisanResponse> getArtisanList() {
        return artisanRepository.findByStatus(ArtisanStatus.VERIFIED).stream()
                .map(ArtisanResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * 获取手作人详情（缓存 5 分钟）
     */
    public ArtisanResponse getArtisanDetail(Long artisanId) {
        Artisan artisan = artisanRepository.findById(artisanId);
        if (artisan == null) {
            throw new BusinessException(ErrorCode.ARTISAN_NOT_FOUND);
        }
        return ArtisanResponse.fromEntity(artisan);
    }

    /**
     * 根据用户ID获取手作人信息
     */
    public ArtisanResponse getArtisanByUserId(Long userId) {
        Artisan artisan = artisanRepository.findByUserId(userId);
        if (artisan == null) {
            return null;
        }
        return ArtisanResponse.fromEntity(artisan);
    }

    /**
     * 申请成为手作人
     */
    public void applyArtisan(Long userId, String name, String bio, String specialty, Integer yearsOfExp, String location) {
        // 检查是否已申请
        Artisan existing = artisanRepository.findByUserId(userId);
        if (existing != null) {
            throw new BusinessException(ErrorCode.ARTISAN_APPLICATION_EXISTS);
        }

        Artisan artisan = new Artisan();
        artisan.setUserId(userId);
        artisan.setName(name);
        artisan.setBio(bio);
        artisan.setSpecialty(specialty);
        artisan.setYearsOfExp(yearsOfExp != null ? yearsOfExp : 0);
        artisan.setLocation(location);
        artisan.setStatus(ArtisanStatus.PENDING);
        artisan.setRating(new java.math.BigDecimal("0.00"));
        artisan.setOrderCount(0);
        artisan.setFanCount(0);
        artisan.setAppliedAt(LocalDateTime.now());
        artisanRepository.insert(artisan);
    }

    /**
     * 搜索手作人
     */
    public List<ArtisanResponse> searchArtisans(String keyword) {
        return artisanRepository.search(keyword).stream()
                .map(ArtisanResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * 更新手作人评分
     */
    @CacheEvict(value = "artisans", key = "'detail:' + #artisanId")
    public void updateArtisanRating(Long artisanId, double rating) {
        artisanRepository.updateRating(artisanId, new java.math.BigDecimal(rating));
    }

    /**
     * 获取所有手作人（包括管理后台使用）
     */
    public List<ArtisanResponse> findAllArtisans() {
        return artisanRepository.selectList(null).stream()
                .map(ArtisanResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * 根据ID获取手作人
     */
    public ArtisanResponse findArtisanById(Long id) {
        Artisan artisan = artisanRepository.findById(id);
        if (artisan == null) {
            throw new BusinessException(ErrorCode.ARTISAN_NOT_FOUND);
        }
        return ArtisanResponse.fromEntity(artisan);
    }

    /**
     * 获取手作人作品列表
     */
    public List<Map<String, Object>> findArtisanProducts(Long artisanId) {
        List<Product> products = productRepository.findByArtisanId(artisanId);
        return products.stream().map(product -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", product.getId());
            item.put("title", product.getTitle());
            item.put("description", product.getDescription());
            item.put("coverImage", product.getCoverImage());
            item.put("price", product.getPrice());
            item.put("isAvailable", product.getIsAvailable());
            item.put("createdAt", product.getCreatedAt());
            return item;
        }).collect(Collectors.toList());
    }
}

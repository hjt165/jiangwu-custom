package com.jiangwu.service;

import com.jiangwu.dto.response.ProductResponse;
import com.jiangwu.entity.Product;
import com.jiangwu.entity.UserFavorite;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.exception.ErrorCode;
import com.jiangwu.repository.ProductImageRepository;
import com.jiangwu.repository.ProductRepository;
import com.jiangwu.repository.UserFavoriteRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 收藏服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class FavoriteService {

    private final UserFavoriteRepository favoriteRepository;
    private final ProductRepository productRepository;
    private final ProductImageRepository productImageRepository;

    /**
     * 收藏作品
     */
    @Transactional
    public void addFavorite(Long userId, Long productId) {
        // 检查作品是否存在
        Product product = productRepository.findById(productId);
        if (product == null) {
            throw new BusinessException(ErrorCode.PRODUCT_NOT_FOUND);
        }

        // 检查是否已收藏
        UserFavorite existing = favoriteRepository.findByUserAndProduct(userId, productId);
        if (existing != null) {
            throw new BusinessException(ErrorCode.FAVORITE_ALREADY_EXISTS);
        }

        // 创建收藏记录
        UserFavorite favorite = new UserFavorite();
        favorite.setUserId(userId);
        favorite.setProductId(productId);
        favoriteRepository.insert(favorite);

        // 更新作品收藏数
        productRepository.updateLikeCount(productId, 1);

        log.info("用户{}收藏作品{}", userId, productId);
    }

    /**
     * 取消收藏
     */
    @Transactional
    public void removeFavorite(Long userId, Long productId) {
        UserFavorite existing = favoriteRepository.findByUserAndProduct(userId, productId);
        if (existing == null) {
            throw new BusinessException(ErrorCode.FAVORITE_NOT_FOUND);
        }

        favoriteRepository.deleteByUserAndProduct(userId, productId);

        // 更新作品收藏数
        productRepository.updateLikeCount(productId, -1);

        log.info("用户{}取消收藏作品{}", userId, productId);
    }

    /**
     * 切换收藏状态
     */
    @Transactional
    public boolean toggleFavorite(Long userId, Long productId) {
        UserFavorite existing = favoriteRepository.findByUserAndProduct(userId, productId);
        if (existing != null) {
            removeFavorite(userId, productId);
            return false;
        } else {
            addFavorite(userId, productId);
            return true;
        }
    }

    /**
     * 检查是否已收藏
     */
    public boolean isFavorited(Long userId, Long productId) {
        return favoriteRepository.findByUserAndProduct(userId, productId) != null;
    }

    /**
     * 获取收藏列表（分页）
     */
    public List<ProductResponse> getFavoriteList(Long userId) {
        List<Long> productIds = favoriteRepository.findProductIdsByUserId(userId);

        return productIds.stream()
                .map(id -> {
                    Product product = productRepository.findById(id);
                    if (product == null) return null;
                    ProductResponse response = ProductResponse.fromEntity(product);
                    List<String> images = productImageRepository.findImageUrlsByProductId(product.getId());
                    response.setImagesFromUrls(images);
                    return response;
                })
                .filter(r -> r != null)
                .collect(Collectors.toList());
    }

    /**
     * 获取收藏产品ID列表
     */
    public List<Long> getFavoriteProductIds(Long userId) {
        return favoriteRepository.findProductIdsByUserId(userId);
    }
}

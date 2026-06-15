package com.jiangwu.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangwu.dto.response.ProductResponse;
import com.jiangwu.entity.Product;
import com.jiangwu.enums.ProductCategory;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.exception.ErrorCode;
import com.jiangwu.common.PageResult;
import com.jiangwu.repository.ProductImageRepository;
import com.jiangwu.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 作品服务
 */
@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final ProductImageRepository productImageRepository;
    private final HistoryService historyService;

    /**
     * 获取作品列表（分页 + 分类筛选）
     */
    public PageResult<ProductResponse> getProductList(int page, int size, String category) {
        Page<Product> pageParam = new Page<>(page, size);

        List<Product> products;
        if (category != null && !category.isEmpty()) {
            ProductCategory cat = ProductCategory.valueOf(category.toUpperCase());
            products = productRepository.findByCategory(cat);
        } else {
            products = productRepository.findFeatured();
        }

        // 手动分页
        int start = (page - 1) * size;
        int end = Math.min(start + size, products.size());
        List<Product> pageProducts = start < products.size() ? products.subList(start, end) : List.of();

        List<ProductResponse> responses = pageProducts.stream()
                .map(this::toResponseWithImages)
                .collect(Collectors.toList());

        long total = products.size();
        long pages = (total + size - 1) / size;
        return new PageResult<>(total, responses, page, size, pages);
    }

    /**
     * 获取作品详情
     */
    public ProductResponse getProductDetail(Long productId) {
        return getProductDetail(productId, null);
    }

    /**
     * 获取作品详情（可选记录浏览历史）
     */
    public ProductResponse getProductDetail(Long productId, Long userId) {
        Product product = productRepository.findById(productId);
        if (product == null) {
            throw new BusinessException(ErrorCode.PRODUCT_NOT_FOUND);
        }
        // 增加浏览量
        productRepository.incrementViewCount(productId);
        // 记录浏览历史（如果提供了 userId）
        if (userId != null) {
            try {
                historyService.recordView(userId, productId);
            } catch (Exception e) {
                // 浏览历史记录失败不影响主流程
            }
        }
        return toResponseWithImages(product);
    }

    /**
     * 搜索作品
     */
    public PageResult<ProductResponse> searchProducts(String keyword, int page, int size) {
        List<Product> products = productRepository.search(keyword);

        int start = (page - 1) * size;
        int end = Math.min(start + size, products.size());
        List<Product> pageProducts = start < products.size() ? products.subList(start, end) : List.of();

        List<ProductResponse> responses = pageProducts.stream()
                .map(this::toResponseWithImages)
                .collect(Collectors.toList());

        long total = products.size();
        long pages = (total + size - 1) / size;
        return new PageResult<>(total, responses, page, size, pages);
    }

    /**
     * 获取推荐作品
     */
    public List<ProductResponse> getFeaturedProducts() {
        return productRepository.findFeatured().stream()
                .map(this::toResponseWithImages)
                .collect(Collectors.toList());
    }

    /**
     * 获取手作人的作品列表
     */
    public PageResult<ProductResponse> getArtisanProducts(Long artisanId, int page, int size) {
        List<Product> products = productRepository.findByArtisanId(artisanId);

        int start = (page - 1) * size;
        int end = Math.min(start + size, products.size());
        List<Product> pageProducts = start < products.size() ? products.subList(start, end) : List.of();

        List<ProductResponse> responses = pageProducts.stream()
                .map(this::toResponseWithImages)
                .collect(Collectors.toList());

        long total = products.size();
        long pages = (total + size - 1) / size;
        return new PageResult<>(total, responses, page, size, pages);
    }

    /**
     * 更新作品评分
     */
    public void updateProductRating(Long productId, double rating) {
        productRepository.updateRating(productId, new java.math.BigDecimal(rating));
    }

    /**
     * 转换为 Response（含图片列表）
     */
    private ProductResponse toResponseWithImages(Product product) {
        ProductResponse response = ProductResponse.fromEntity(product);
        if (response != null) {
            List<String> images = productImageRepository.findImageUrlsByProductId(product.getId());
            response.setImagesFromUrls(images);
        }
        return response;
    }
}

package com.jiangwu.service;

import com.jiangwu.dto.response.ProductResponse;
import com.jiangwu.entity.BrowseHistory;
import com.jiangwu.entity.Product;
import com.jiangwu.repository.BrowseHistoryRepository;
import com.jiangwu.repository.ProductImageRepository;
import com.jiangwu.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 浏览历史服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class HistoryService {

    private final BrowseHistoryRepository historyRepository;
    private final ProductRepository productRepository;
    private final ProductImageRepository productImageRepository;

    /**
     * 记录浏览（去重：同一用户同一产品只保留最新一条）
     */
    @Transactional
    public void recordView(Long userId, Long productId) {
        // 先删除旧记录
        historyRepository.deleteByUserAndProduct(userId, productId);

        // 插入新记录
        BrowseHistory history = new BrowseHistory();
        history.setUserId(userId);
        history.setProductId(productId);
        historyRepository.insert(history);

        log.debug("用户{}浏览作品{}", userId, productId);
    }

    /**
     * 获取浏览历史列表（分页）
     */
    public List<ProductResponse> getHistoryList(Long userId) {
        List<Long> productIds = historyRepository.findProductIdsByUserId(userId);

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
     * 清空浏览历史
     */
    @Transactional
    public void clearHistory(Long userId) {
        historyRepository.clearByUserId(userId);
        log.info("用户{}清空浏览历史", userId);
    }

    /**
     * 获取浏览产品ID列表
     */
    public List<Long> getHistoryProductIds(Long userId) {
        return historyRepository.findProductIdsByUserId(userId);
    }
}

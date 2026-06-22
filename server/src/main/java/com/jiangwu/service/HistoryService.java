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
import java.util.Map;
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
     * 获取浏览历史列表（批量查询优化，避免 N+1）
     */
    public List<ProductResponse> getHistoryList(Long userId) {
        List<Long> productIds = historyRepository.findProductIdsByUserId(userId);
        if (productIds.isEmpty()) {
            return List.of();
        }

        // 批量查询产品
        List<Product> products = productRepository.findByIds(productIds);
        Map<Long, Product> productMap = products.stream()
                .collect(Collectors.toMap(Product::getId, p -> p));

        // 批量查询图片（单次 SQL）
        Map<Long, List<String>> imagesMap = new java.util.LinkedHashMap<>();
        if (!productIds.isEmpty()) {
            List<Map<String, Object>> rows = productImageRepository.findImageUrlsByProductIds(productIds);
            for (Map<String, Object> row : rows) {
                Long pid = ((Number) row.get("product_id")).longValue();
                String url = (String) row.get("image_url");
                imagesMap.computeIfAbsent(pid, k -> new java.util.ArrayList<>()).add(url);
            }
        }

        return productIds.stream()
                .map(id -> {
                    Product product = productMap.get(id);
                    if (product == null) return null;
                    ProductResponse response = ProductResponse.fromEntity(product);
                    if (imagesMap.containsKey(id)) {
                        response.setImagesFromUrls(imagesMap.get(id));
                    }
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

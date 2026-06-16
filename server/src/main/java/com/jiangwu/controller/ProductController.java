package com.jiangwu.controller;

import com.jiangwu.common.PageResult;
import com.jiangwu.common.Result;
import com.jiangwu.dto.response.ProductResponse;
import com.jiangwu.service.AiService;
import com.jiangwu.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 作品控制器
 */
@RestController
@RequestMapping("/product")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;
    private final AiService aiService;

    /**
     * 获取作品列表（分页 + 分类筛选）
     */
    @GetMapping("/list")
    public Result<PageResult<ProductResponse>> getProductList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String category) {
        PageResult<ProductResponse> result = productService.getProductList(page, size, category);
        return Result.success(result);
    }

    /**
     * 获取作品详情 (含 AI 推荐手作人)
     */
    @GetMapping("/{id}")
    public Result<Map<String, Object>> getProductDetail(@PathVariable Long id) {
        ProductResponse product = productService.getProductDetail(id);

        Map<String, Object> response = new HashMap<>();
        response.put("product", product);

        // AI 推荐匹配的手作人
        if (product != null && product.getCategory() != null) {
            try {
                Map<String, Object> recommendation = aiService.recommendArtisan(
                        product.getCategory(),
                        null, 0, 99999, 30, 5
                );
                if (recommendation != null && !recommendation.containsKey("error")) {
                    response.put("recommendedArtisans", recommendation.get("artisans"));
                }
            } catch (Exception e) {
                // AI 服务不可用时不影响主流程
            }
        }

        return Result.success(response);
    }

    /**
     * 搜索作品
     */
    @GetMapping("/search")
    public Result<PageResult<ProductResponse>> searchProducts(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        PageResult<ProductResponse> result = productService.searchProducts(keyword, page, size);
        return Result.success(result);
    }

    /**
     * 获取推荐作品
     */
    @GetMapping("/featured")
    public Result<List<ProductResponse>> getFeaturedProducts() {
        List<ProductResponse> result = productService.getFeaturedProducts();
        return Result.success(result);
    }

    /**
     * 获取手作人的作品列表
     */
    @GetMapping("/artisan/{artisanId}")
    public Result<PageResult<ProductResponse>> getArtisanProducts(
            @PathVariable Long artisanId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        PageResult<ProductResponse> result = productService.getArtisanProducts(artisanId, page, size);
        return Result.success(result);
    }
}

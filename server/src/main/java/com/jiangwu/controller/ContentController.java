package com.jiangwu.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.jiangwu.common.Result;
import com.jiangwu.entity.ProductImage;
import com.jiangwu.entity.Review;
import com.jiangwu.entity.User;
import com.jiangwu.repository.ProductImageRepository;
import com.jiangwu.repository.ReviewRepository;
import com.jiangwu.repository.UserRepository;
import com.jiangwu.utils.JWTUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 内容审核控制器
 */
@RestController
@RequestMapping("/content")
@RequiredArgsConstructor
public class ContentController {

    private final ProductImageRepository imageRepository;
    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;
    private final JWTUtil jwtUtil;

    // ==================== 图片审核 ====================

    /**
     * 获取待审核图片列表
     */
    @GetMapping("/image/list")
    public Result<Map<String, Object>> getImageReviewList(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        QueryWrapper<ProductImage> wrapper = new QueryWrapper<>();
        if (status != null) {
            wrapper.eq("review_status", status);
        } else {
            wrapper.eq("review_status", 0); // 默认待审核
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like("description", keyword);
        }
        wrapper.orderByDesc("created_at");

        // 查询总数
        long total = imageRepository.selectCount(wrapper);

        // 分页查询
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<ProductImage> images = imageRepository.selectList(wrapper);

        // 获取用户信息
        List<Map<String, Object>> result = images.stream().map(image -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", image.getId());
            item.put("imageUrl", image.getImageUrl());
            item.put("description", image.getDescription());
            item.put("reviewStatus", image.getReviewStatus());
            item.put("createdAt", image.getCreatedAt());

            // 获取关联的产品信息
            // TODO: 关联产品信息查询

            return item;
        }).collect(Collectors.toList());

        Map<String, Object> response = new HashMap<>();
        response.put("list", result);
        response.put("total", total);
        response.put("page", page);
        response.put("size", size);
        return Result.success(response);
    }

    /**
     * 审核图片
     */
    @PutMapping("/image/{id}/review")
    public Result<Void> reviewImage(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        
        Long reviewerId = extractUserId(request);
        String action = (String) body.get("action");
        String remark = (String) body.get("remark");

        ProductImage image = imageRepository.selectById(id);
        if (image == null) {
            return Result.error(404, "图片不存在");
        }

        image.setReviewStatus("pass".equals(action) ? 1 : 2);
        image.setReviewRemark(remark);
        image.setReviewerId(reviewerId);
        image.setReviewedAt(LocalDateTime.now());
        imageRepository.updateById(image);

        return Result.success();
    }

    /**
     * 批量审核图片
     */
    @PutMapping("/image/batch-review")
    public Result<Void> batchReviewImages(
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        
        Long reviewerId = extractUserId(request);
        List<Long> ids = ((List<?>) body.get("ids")).stream()
                .map(id -> Long.valueOf(id.toString()))
                .collect(Collectors.toList());
        String action = (String) body.get("action");
        String remark = (String) body.get("remark");

        int status = "pass".equals(action) ? 1 : 2;
        for (Long id : ids) {
            ProductImage image = imageRepository.selectById(id);
            if (image != null) {
                image.setReviewStatus(status);
                image.setReviewRemark(remark);
                image.setReviewerId(reviewerId);
                image.setReviewedAt(LocalDateTime.now());
                imageRepository.updateById(image);
            }
        }

        return Result.success();
    }

    // ==================== 评论审核 ====================

    /**
     * 获取待审核评论列表
     */
    @GetMapping("/comment/list")
    public Result<Map<String, Object>> getCommentReviewList(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Integer minRating,
            @RequestParam(required = false) Integer maxRating,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        QueryWrapper<Review> wrapper = new QueryWrapper<>();
        wrapper.eq("deleted", 0);
        if (status != null) {
            wrapper.eq("review_status", status);
        } else {
            wrapper.eq("review_status", 0); // 默认待审核
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like("content", keyword);
        }
        if (minRating != null) {
            wrapper.ge("rating", minRating);
        }
        if (maxRating != null) {
            wrapper.le("rating", maxRating);
        }
        wrapper.orderByDesc("created_at");

        // 查询总数
        long total = reviewRepository.selectCount(wrapper);

        // 分页查询
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<Review> reviews = reviewRepository.selectList(wrapper);

        // 获取用户信息
        List<Map<String, Object>> result = reviews.stream().map(review -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", review.getId());
            item.put("orderId", review.getOrderId());
            item.put("userId", review.getUserId());
            item.put("artisanId", review.getArtisanId());
            item.put("rating", review.getRating());
            item.put("content", review.getContent());
            item.put("images", review.getImages());
            item.put("tags", review.getTags());
            item.put("isAnonymous", review.getIsAnonymous());
            item.put("reviewStatus", review.getReviewStatus());
            item.put("createdAt", review.getCreatedAt());

            // 获取用户名
            User user = userRepository.selectById(review.getUserId());
            if (user != null) {
                item.put("userName", user.getNickname());
                item.put("userAvatar", user.getAvatar());
            }

            return item;
        }).collect(Collectors.toList());

        Map<String, Object> response = new HashMap<>();
        response.put("list", result);
        response.put("total", total);
        response.put("page", page);
        response.put("size", size);
        return Result.success(response);
    }

    /**
     * 审核评论
     */
    @PutMapping("/comment/{id}/review")
    public Result<Void> reviewComment(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        
        Long reviewerId = extractUserId(request);
        String action = (String) body.get("action");
        String remark = (String) body.get("remark");

        Review review = reviewRepository.selectById(id);
        if (review == null) {
            return Result.error(404, "评论不存在");
        }

        review.setReviewStatus("pass".equals(action) ? 1 : 2);
        review.setReviewRemark(remark);
        review.setReviewerId(reviewerId);
        review.setReviewedAt(LocalDateTime.now());
        reviewRepository.updateById(review);

        return Result.success();
    }

    /**
     * 批量审核评论
     */
    @PutMapping("/comment/batch-review")
    public Result<Void> batchReviewComments(
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        
        Long reviewerId = extractUserId(request);
        List<Long> ids = ((List<?>) body.get("ids")).stream()
                .map(id -> Long.valueOf(id.toString()))
                .collect(Collectors.toList());
        String action = (String) body.get("action");
        String remark = (String) body.get("remark");

        int status = "pass".equals(action) ? 1 : 2;
        for (Long id : ids) {
            Review review = reviewRepository.selectById(id);
            if (review != null) {
                review.setReviewStatus(status);
                review.setReviewRemark(remark);
                review.setReviewerId(reviewerId);
                review.setReviewedAt(LocalDateTime.now());
                reviewRepository.updateById(review);
            }
        }

        return Result.success();
    }

    /**
     * 从请求中提取用户ID
     */
    private Long extractUserId(HttpServletRequest request) {
        String token = jwtUtil.extractToken(request.getHeader("Authorization"));
        return jwtUtil.parseUserId(token);
    }
}

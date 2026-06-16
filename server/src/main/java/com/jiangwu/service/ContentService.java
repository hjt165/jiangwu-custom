package com.jiangwu.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.jiangwu.entity.ProductImage;
import com.jiangwu.entity.Review;
import com.jiangwu.entity.User;
import com.jiangwu.repository.ProductImageRepository;
import com.jiangwu.repository.ReviewRepository;
import com.jiangwu.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 内容审核服务
 */
@Service
@RequiredArgsConstructor
public class ContentService {

    private final ProductImageRepository imageRepository;
    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;

    // ==================== 图片审核 ====================

    /**
     * 获取待审核图片列表
     */
    public Map<String, Object> getImageReviewList(String keyword, Integer status, int page, int size) {
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

        long total = imageRepository.selectCount(wrapper);
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<ProductImage> images = imageRepository.selectList(wrapper);

        List<Map<String, Object>> result = images.stream().map(image -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", image.getId());
            item.put("imageUrl", image.getImageUrl());
            item.put("description", image.getDescription());
            item.put("reviewStatus", image.getReviewStatus());
            item.put("createdAt", image.getCreatedAt());
            return item;
        }).collect(Collectors.toList());

        Map<String, Object> response = new HashMap<>();
        response.put("list", result);
        response.put("total", total);
        response.put("page", page);
        response.put("size", size);
        return response;
    }

    /**
     * 审核图片
     */
    public void reviewImage(Long id, String action, String remark, Long reviewerId) {
        ProductImage image = imageRepository.selectById(id);
        if (image == null) {
            throw new RuntimeException("图片不存在");
        }

        image.setReviewStatus("pass".equals(action) ? 1 : 2);
        image.setReviewRemark(remark);
        image.setReviewerId(reviewerId);
        image.setReviewedAt(LocalDateTime.now());
        imageRepository.updateById(image);
    }

    /**
     * 批量审核图片
     */
    public void batchReviewImages(List<Long> ids, String action, String remark, Long reviewerId) {
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
    }

    // ==================== 评论审核 ====================

    /**
     * 获取待审核评论列表
     */
    public Map<String, Object> getCommentReviewList(String keyword, Integer status, Integer minRating, Integer maxRating, int page, int size) {
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

        long total = reviewRepository.selectCount(wrapper);
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        List<Review> reviews = reviewRepository.selectList(wrapper);

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
        return response;
    }

    /**
     * 审核评论
     */
    public void reviewComment(Long id, String action, String remark, Long reviewerId) {
        Review review = reviewRepository.selectById(id);
        if (review == null) {
            throw new RuntimeException("评论不存在");
        }

        review.setReviewStatus("pass".equals(action) ? 1 : 2);
        review.setReviewRemark(remark);
        review.setReviewerId(reviewerId);
        review.setReviewedAt(LocalDateTime.now());
        reviewRepository.updateById(review);
    }

    /**
     * 批量审核评论
     */
    public void batchReviewComments(List<Long> ids, String action, String remark, Long reviewerId) {
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
    }
}

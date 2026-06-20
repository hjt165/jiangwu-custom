package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.dto.response.ArtisanResponse;
import com.jiangwu.entity.Review;
import com.jiangwu.repository.ReviewRepository;
import com.jiangwu.service.ArtisanFollowService;
import com.jiangwu.service.ArtisanService;
import com.jiangwu.utils.CurrentUserUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 手作人控制器
 */
@RestController
@RequestMapping("/artisan")
@RequiredArgsConstructor
public class ArtisanController {

    private final ArtisanService artisanService;
    private final ArtisanFollowService artisanFollowService;
    private final ReviewRepository reviewRepository;
    private final CurrentUserUtil currentUserUtil;

    /**
     * 获取手作人列表
     */
    @GetMapping("/list")
    public Result<List<ArtisanResponse>> getArtisanList() {
        List<ArtisanResponse> list = artisanService.findAllArtisans();
        return Result.success(list);
    }

    /**
     * 获取手作人详情
     */
    @GetMapping("/{id}")
    public Result<ArtisanResponse> getArtisanDetail(@PathVariable Long id) {
        ArtisanResponse artisan = artisanService.getArtisanDetail(id);
        return Result.success(artisan);
    }

    /**
     * 获取手作人作品列表
     */
    @GetMapping("/{id}/products")
    public Result<List<Map<String, Object>>> getArtisanProducts(@PathVariable Long id) {
        List<Map<String, Object>> list = artisanService.findArtisanProducts(id);
        return Result.success(list);
    }

    /**
     * 获取手作人评价列表
     */
    @GetMapping("/{id}/reviews")
    public Result<List<Review>> getArtisanReviews(@PathVariable Long id) {
        List<Review> reviews = reviewRepository.findByArtisanId(id);
        return Result.success(reviews);
    }

    /**
     * 关注手作人
     */
    @PostMapping("/{id}/follow")
    public Result<Map<String, Boolean>> followArtisan(@PathVariable Long id, HttpServletRequest request) {
        Long userId = currentUserUtil.extractUserId(request);
        return Result.success(artisanFollowService.follow(userId, id));
    }

    /**
     * 取消关注手作人
     */
    @DeleteMapping("/{id}/follow")
    public Result<Map<String, Boolean>> unfollowArtisan(@PathVariable Long id, HttpServletRequest request) {
        Long userId = currentUserUtil.extractUserId(request);
        return Result.success(artisanFollowService.unfollow(userId, id));
    }

    /**
     * 检查是否已关注
     */
    @GetMapping("/{id}/follow/check")
    public Result<Map<String, Boolean>> checkFollow(@PathVariable Long id, HttpServletRequest request) {
        Long userId = currentUserUtil.extractUserId(request);
        return Result.success(Map.of("isFollowing", artisanFollowService.isFollowing(userId, id)));
    }

    /**
     * 获取关注列表
     */
    @GetMapping("/follow/list")
    public Result<List<Map<String, Object>>> getFollowList(HttpServletRequest request) {
        Long userId = currentUserUtil.extractUserId(request);
        return Result.success(artisanFollowService.getFollowList(userId));
    }

    /**
     * 获取关注数量
     */
    @GetMapping("/follow/count")
    public Result<Long> getFollowCount(HttpServletRequest request) {
        Long userId = currentUserUtil.extractUserId(request);
        return Result.success(artisanFollowService.getFollowCount(userId));
    }
}

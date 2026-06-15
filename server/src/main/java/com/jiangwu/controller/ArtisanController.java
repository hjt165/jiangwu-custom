package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.dto.response.ArtisanResponse;
import com.jiangwu.entity.Review;
import com.jiangwu.entity.UserFollow;
import com.jiangwu.entity.Artisan;
import com.jiangwu.repository.ReviewRepository;
import com.jiangwu.repository.UserFollowRepository;
import com.jiangwu.repository.ArtisanRepository;
import com.jiangwu.service.ArtisanService;
import com.jiangwu.utils.JWTUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 手作人控制器
 */
@RestController
@RequestMapping("/artisan")
@RequiredArgsConstructor
public class ArtisanController {

    private final ArtisanService artisanService;
    private final ReviewRepository reviewRepository;
    private final UserFollowRepository userFollowRepository;
    private final ArtisanRepository artisanRepository;
    private final JWTUtil jwtUtil;

    /**
     * 获取手作人列表
     */
    @GetMapping("/list")
    public Result<List<ArtisanResponse>> getArtisanList() {
        List<ArtisanResponse> result = artisanService.getArtisanList();
        return Result.success(result);
    }

    /**
     * 获取手作人详情
     */
    @GetMapping("/{id}")
    public Result<ArtisanResponse> getArtisanDetail(@PathVariable Long id) {
        ArtisanResponse response = artisanService.getArtisanDetail(id);
        return Result.success(response);
    }

    /**
     * 申请成为手作人
     */
    @PostMapping("/apply")
    public Result<Void> applyArtisan(HttpServletRequest request,
                                     @RequestParam String name,
                                     @RequestParam(required = false) String bio,
                                     @RequestParam(required = false) String specialty,
                                     @RequestParam(required = false) Integer yearsOfExp,
                                     @RequestParam(required = false) String location) {
        Long userId = extractUserId(request);
        artisanService.applyArtisan(userId, name, bio, specialty, yearsOfExp, location);
        return Result.success();
    }

    /**
     * 搜索手作人
     */
    @GetMapping("/search")
    public Result<List<ArtisanResponse>> searchArtisans(@RequestParam String keyword) {
        List<ArtisanResponse> result = artisanService.searchArtisans(keyword);
        return Result.success(result);
    }

    /**
     * 获取当前用户的手作人信息
     */
    @GetMapping("/my")
    public Result<ArtisanResponse> getMyArtisanInfo(HttpServletRequest request) {
        Long userId = extractUserId(request);
        ArtisanResponse response = artisanService.getArtisanByUserId(userId);
        return Result.success(response);
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
        Long userId = extractUserId(request);

        // 检查是否已关注
        UserFollow existing = userFollowRepository.findByUserIdAndArtisanId(userId, id);
        if (existing != null) {
            Map<String, Boolean> result = new HashMap<>();
            result.put("isFollowing", true);
            return Result.success(result);
        }

        // 创建关注
        UserFollow follow = new UserFollow();
        follow.setUserId(userId);
        follow.setArtisanId(id);
        userFollowRepository.insert(follow);

        // 更新手作人粉丝数
        Artisan artisan = artisanRepository.selectById(id);
        if (artisan != null) {
            artisan.setFanCount(artisan.getFanCount() + 1);
            artisanRepository.updateById(artisan);
        }

        Map<String, Boolean> result = new HashMap<>();
        result.put("isFollowing", true);
        return Result.success(result);
    }

    /**
     * 取消关注手作人
     */
    @DeleteMapping("/{id}/follow")
    public Result<Map<String, Boolean>> unfollowArtisan(@PathVariable Long id, HttpServletRequest request) {
        Long userId = extractUserId(request);

        // 删除关注
        userFollowRepository.findByUserIdAndArtisanId(userId, id);
        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<UserFollow> wrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        wrapper.eq("user_id", userId).eq("artisan_id", id);
        userFollowRepository.delete(wrapper);

        // 更新手作人粉丝数
        Artisan artisan = artisanRepository.selectById(id);
        if (artisan != null && artisan.getFanCount() > 0) {
            artisan.setFanCount(artisan.getFanCount() - 1);
            artisanRepository.updateById(artisan);
        }

        Map<String, Boolean> result = new HashMap<>();
        result.put("isFollowing", false);
        return Result.success(result);
    }

    /**
     * 检查是否已关注
     */
    @GetMapping("/{id}/follow/check")
    public Result<Map<String, Boolean>> checkFollow(@PathVariable Long id, HttpServletRequest request) {
        Long userId = extractUserId(request);

        UserFollow follow = userFollowRepository.findByUserIdAndArtisanId(userId, id);

        Map<String, Boolean> result = new HashMap<>();
        result.put("isFollowing", follow != null);
        return Result.success(result);
    }

    /**
     * 获取关注列表
     */
    @GetMapping("/follow/list")
    public Result<List<Map<String, Object>>> getFollowList(HttpServletRequest request) {
        Long userId = extractUserId(request);

        List<UserFollow> follows = userFollowRepository.findByUserId(userId);

        List<Map<String, Object>> result = follows.stream().map(follow -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", follow.getId());
            item.put("createdAt", follow.getCreatedAt());

            Artisan artisan = artisanRepository.selectById(follow.getArtisanId());
            if (artisan != null) {
                item.put("artisanId", artisan.getId());
                item.put("name", artisan.getName());
                item.put("avatar", artisan.getAvatar());
                item.put("specialty", artisan.getSpecialty());
                item.put("rating", artisan.getRating());
            }
            return item;
        }).collect(Collectors.toList());

        return Result.success(result);
    }

    /**
     * 获取关注数量
     */
    @GetMapping("/follow/count")
    public Result<Long> getFollowCount(HttpServletRequest request) {
        Long userId = extractUserId(request);

        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<UserFollow> wrapper = new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        wrapper.eq("user_id", userId);
        long count = userFollowRepository.selectCount(wrapper);

        return Result.success(count);
    }

    /**
     * 从请求中提取用户ID
     */
    private Long extractUserId(HttpServletRequest request) {
        String token = jwtUtil.extractToken(request.getHeader("Authorization"));
        return jwtUtil.parseUserId(token);
    }
}

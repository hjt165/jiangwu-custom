package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.dto.response.ProductResponse;
import com.jiangwu.service.FavoriteService;
import com.jiangwu.utils.JWTUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 收藏控制器
 */
@RestController
@RequestMapping("/favorite")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;
    private final JWTUtil jwtUtil;

    /**
     * 收藏作品
     */
    @PostMapping("/{productId}")
    public Result<Void> addFavorite(@PathVariable Long productId, HttpServletRequest request) {
        Long userId = extractUserId(request);
        favoriteService.addFavorite(userId, productId);
        return Result.success();
    }

    /**
     * 取消收藏
     */
    @DeleteMapping("/{productId}")
    public Result<Void> removeFavorite(@PathVariable Long productId, HttpServletRequest request) {
        Long userId = extractUserId(request);
        favoriteService.removeFavorite(userId, productId);
        return Result.success();
    }

    /**
     * 切换收藏状态
     */
    @PostMapping("/{productId}/toggle")
    public Result<Map<String, Boolean>> toggleFavorite(@PathVariable Long productId, HttpServletRequest request) {
        Long userId = extractUserId(request);
        boolean isFavorited = favoriteService.toggleFavorite(userId, productId);
        return Result.success(Map.of("isFavorited", isFavorited));
    }

    /**
     * 检查是否已收藏
     */
    @GetMapping("/check/{productId}")
    public Result<Map<String, Boolean>> checkFavorite(@PathVariable Long productId, HttpServletRequest request) {
        Long userId = extractUserId(request);
        boolean isFavorited = favoriteService.isFavorited(userId, productId);
        return Result.success(Map.of("isFavorited", isFavorited));
    }

    /**
     * 获取收藏列表
     */
    @GetMapping("/list")
    public Result<List<ProductResponse>> getFavoriteList(HttpServletRequest request) {
        Long userId = extractUserId(request);
        List<ProductResponse> list = favoriteService.getFavoriteList(userId);
        return Result.success(list);
    }

    /**
     * 从请求中提取用户ID
     */
    private Long extractUserId(HttpServletRequest request) {
        String token = jwtUtil.extractToken(request.getHeader("Authorization"));
        return jwtUtil.parseUserId(token);
    }
}

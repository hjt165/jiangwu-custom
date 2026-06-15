package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.dto.response.ArtisanResponse;
import com.jiangwu.service.ArtisanService;
import com.jiangwu.utils.JWTUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 手作人控制器
 */
@RestController
@RequestMapping("/artisan")
@RequiredArgsConstructor
public class ArtisanController {

    private final ArtisanService artisanService;
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
     * 从请求中提取用户ID
     */
    private Long extractUserId(HttpServletRequest request) {
        String token = jwtUtil.extractToken(request.getHeader("Authorization"));
        return jwtUtil.parseUserId(token);
    }
}

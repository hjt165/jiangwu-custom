package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.service.ContentService;
import com.jiangwu.utils.CurrentUserUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 内容审核控制器
 */
@RestController
@RequestMapping("/admin/content")
@RequiredArgsConstructor
public class ContentController {

    private final ContentService contentService;
    private final CurrentUserUtil currentUserUtil;

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
        return Result.success(contentService.getImageReviewList(keyword, status, page, size));
    }

    /**
     * 审核图片
     */
    @PutMapping("/image/{id}/review")
    public Result<Void> reviewImage(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        Long reviewerId = currentUserUtil.extractUserId(request);
        String action = (String) body.get("action");
        String remark = (String) body.get("remark");
        contentService.reviewImage(id, action, remark, reviewerId);
        return Result.success();
    }

    /**
     * 批量审核图片
     */
    @PutMapping("/image/batch-review")
    public Result<Void> batchReviewImages(
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        Long reviewerId = currentUserUtil.extractUserId(request);
        List<Long> ids = ((List<?>) body.get("ids")).stream()
                .map(id -> Long.valueOf(id.toString()))
                .toList();
        String action = (String) body.get("action");
        String remark = (String) body.get("remark");
        contentService.batchReviewImages(ids, action, remark, reviewerId);
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
        return Result.success(contentService.getCommentReviewList(keyword, status, minRating, maxRating, page, size));
    }

    /**
     * 审核评论
     */
    @PutMapping("/comment/{id}/review")
    public Result<Void> reviewComment(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        Long reviewerId = currentUserUtil.extractUserId(request);
        String action = (String) body.get("action");
        String remark = (String) body.get("remark");
        contentService.reviewComment(id, action, remark, reviewerId);
        return Result.success();
    }

    /**
     * 批量审核评论
     */
    @PutMapping("/comment/batch-review")
    public Result<Void> batchReviewComments(
            @RequestBody Map<String, Object> body,
            HttpServletRequest request) {
        Long reviewerId = currentUserUtil.extractUserId(request);
        List<Long> ids = ((List<?>) body.get("ids")).stream()
                .map(id -> Long.valueOf(id.toString()))
                .toList();
        String action = (String) body.get("action");
        String remark = (String) body.get("remark");
        contentService.batchReviewComments(ids, action, remark, reviewerId);
        return Result.success();
    }

}

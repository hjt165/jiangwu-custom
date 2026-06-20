package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.entity.Feedback;
import com.jiangwu.service.FeedbackService;
import com.jiangwu.utils.CurrentUserUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 意见反馈控制器
 */
@RestController
@RequestMapping("/feedback")
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;
    private final CurrentUserUtil currentUserUtil;

    /**
     * 提交反馈
     */
    @PostMapping("/submit")
    public Result<Feedback> submit(HttpServletRequest request,
                                   @RequestBody Map<String, String> body) {
        Long userId = currentUserUtil.extractUserId(request);
        String content = body.get("content");
        String contact = body.get("contact");
        return Result.success(feedbackService.submit(userId, content, contact));
    }

    /**
     * 获取反馈列表
     */
    @GetMapping("/list")
    public Result<Map<String, Object>> getList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return Result.success(Map.of(
                "data", feedbackService.getList(page, size),
                "total", feedbackService.getCount()
        ));
    }
}

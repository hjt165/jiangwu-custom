package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.service.StatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 统计数据控制器
 */
@RestController
@RequestMapping("/stats")
@RequiredArgsConstructor
public class StatsController {

    private final StatsService statsService;

    /**
     * 获取仪表盘概览数据
     */
    @GetMapping("/dashboard")
    public Result<Map<String, Object>> getDashboard() {
        return Result.success(statsService.getDashboard());
    }

    /**
     * 获取交易统计数据
     */
    @GetMapping("/transaction")
    public Result<Map<String, Object>> getTransactionStats(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        return Result.success(statsService.getTransactionStats(startDate, endDate));
    }

    /**
     * 获取用户行为统计数据
     */
    @GetMapping("/user")
    public Result<Map<String, Object>> getUserStats(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        return Result.success(statsService.getUserStats(startDate, endDate));
    }
}

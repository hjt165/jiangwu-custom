package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.service.BlockchainService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 区块链溯源控制器
 * 处理存证记录查询、真伪验证、溯源链获取等
 */
@Slf4j
@RestController
@RequestMapping("/blockchain")
@RequiredArgsConstructor
public class BlockchainController {

    private final BlockchainService blockchainService;

    /**
     * 获取订单溯源记录列表
     */
    @GetMapping("/records")
    public Result<List<Map<String, Object>>> getRecords(@RequestParam Long orderId) {
        return Result.success(blockchainService.getRecords(orderId));
    }

    /**
     * 获取溯源记录详情
     */
    @GetMapping("/record/{id}")
    public Result<Map<String, Object>> getRecordDetail(@PathVariable Long id) {
        return Result.success(blockchainService.getRecordDetail(id));
    }

    /**
     * 验证存证真伪
     */
    @PostMapping("/verify")
    public Result<Map<String, Object>> verifyRecord(@RequestBody Map<String, Object> body) {
        Long recordId = Long.valueOf(body.get("recordId").toString());
        return Result.success(blockchainService.verifyRecord(recordId));
    }

    /**
     * 获取订单完整溯源链
     */
    @GetMapping("/trace")
    public Result<Map<String, Object>> getTraceChain(@RequestParam Long orderId) {
        return Result.success(blockchainService.getTraceChain(orderId));
    }

    /**
     * 下载存证证书
     */
    @GetMapping("/certificate")
    public Result<Map<String, String>> downloadCertificate(@RequestParam Long recordId) {
        return Result.success(blockchainService.downloadCertificate(recordId));
    }
}

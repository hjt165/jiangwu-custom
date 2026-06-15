package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.entity.BlockchainRecord;
import com.jiangwu.enums.BlockchainType;
import com.jiangwu.repository.BlockchainRecordRepository;
import com.jiangwu.utils.JWTUtil;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 区块链溯源控制器
 * 处理存证记录查询、真伪验证、溯源链获取等
 */
@Slf4j
@RestController
@RequestMapping("/blockchain")
@RequiredArgsConstructor
public class BlockchainController {

    private final BlockchainRecordRepository blockchainRecordRepository;
    private final JWTUtil jwtUtil;

    /**
     * 获取订单溯源记录列表
     */
    @GetMapping("/records")
    public Result<List<Map<String, Object>>> getRecords(@RequestParam Long orderId) {
        log.info("获取订单溯源记录: orderId={}", orderId);

        List<BlockchainRecord> records = blockchainRecordRepository.findByOrderId(orderId);

        List<Map<String, Object>> result = records.stream().map(record -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", record.getId());
            item.put("orderId", record.getOrderId());
            item.put("type", record.getType().getCode());
            item.put("typeName", record.getType().getName());
            item.put("transactionId", record.getTransactionId());
            item.put("blockHash", record.getBlockHash());
            item.put("dataHash", record.getDataHash());
            item.put("evidenceData", record.getEvidenceData());
            item.put("certificateUrl", record.getCertificateUrl());
            item.put("timestamp", record.getTimestamp());
            item.put("isVerified", record.getIsVerified());
            item.put("createdAt", record.getCreatedAt());
            return item;
        }).collect(Collectors.toList());

        return Result.success(result);
    }

    /**
     * 获取溯源记录详情
     */
    @GetMapping("/record/{id}")
    public Result<Map<String, Object>> getRecordDetail(@PathVariable Long id) {
        log.info("获取溯源记录详情: id={}", id);

        BlockchainRecord record = blockchainRecordRepository.findById(id);
        if (record == null) {
            return Result.error(404, "溯源记录不存在");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", record.getId());
        result.put("orderId", record.getOrderId());
        result.put("type", record.getType().getCode());
        result.put("typeName", record.getType().getName());
        result.put("transactionId", record.getTransactionId());
        result.put("blockHash", record.getBlockHash());
        result.put("dataHash", record.getDataHash());
        result.put("evidenceData", record.getEvidenceData());
        result.put("certificateUrl", record.getCertificateUrl());
        result.put("timestamp", record.getTimestamp());
        result.put("isVerified", record.getIsVerified());
        result.put("createdAt", record.getCreatedAt());

        return Result.success(result);
    }

    /**
     * 验证存证真伪
     */
    @PostMapping("/verify")
    public Result<Map<String, Object>> verifyRecord(@RequestBody Map<String, Object> body) {
        Long recordId = Long.valueOf(body.get("recordId").toString());
        log.info("验证存证真伪: recordId={}", recordId);

        BlockchainRecord record = blockchainRecordRepository.findById(recordId);
        if (record == null) {
            return Result.error(404, "溯源记录不存在");
        }

        // TODO: 调用区块链API验证哈希
        // 实际项目中需要：
        // 1. 根据transactionId查询链上数据
        // 2. 比对blockHash是否一致
        // 3. 更新isVerified状态

        Map<String, Object> result = new HashMap<>();
        result.put("valid", true);
        result.put("message", "存证验证通过");
        result.put("verifiedAt", LocalDateTime.now());
        result.put("blockHash", record.getBlockHash());

        return Result.success(result);
    }

    /**
     * 获取订单完整溯源链
     */
    @GetMapping("/trace")
    public Result<Map<String, Object>> getTraceChain(@RequestParam Long orderId) {
        log.info("获取订单溯源链: orderId={}", orderId);

        List<BlockchainRecord> records = blockchainRecordRepository.findByOrderId(orderId);

        // 统计验证状态
        int totalSteps = records.size();
        int verifiedSteps = (int) records.stream()
                .filter(BlockchainRecord::getIsVerified)
                .count();

        Map<String, Object> result = new HashMap<>();
        result.put("orderId", orderId);
        result.put("records", records.stream().map(record -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", record.getId());
            item.put("type", record.getType().getCode());
            item.put("typeName", record.getType().getName());
            item.put("timestamp", record.getTimestamp());
            item.put("isVerified", record.getIsVerified());
            return item;
        }).collect(Collectors.toList()));
        result.put("totalSteps", totalSteps);
        result.put("verifiedSteps", verifiedSteps);

        return Result.success(result);
    }

    /**
     * 下载存证证书
     */
    @GetMapping("/certificate")
    public Result<Map<String, String>> downloadCertificate(@RequestParam Long recordId) {
        log.info("下载存证证书: recordId={}", recordId);

        BlockchainRecord record = blockchainRecordRepository.findById(recordId);
        if (record == null) {
            return Result.error(404, "溯源记录不存在");
        }

        Map<String, String> result = new HashMap<>();
        result.put("certificateUrl", record.getCertificateUrl() != null ? record.getCertificateUrl() : "");

        return Result.success(result);
    }

    /**
     * 从请求中提取用户ID
     */
    private Long extractUserId(HttpServletRequest request) {
        String token = jwtUtil.extractToken(request.getHeader("Authorization"));
        return jwtUtil.parseUserId(token);
    }
}

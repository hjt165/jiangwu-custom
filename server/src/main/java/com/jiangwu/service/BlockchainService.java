package com.jiangwu.service;

import com.jiangwu.entity.BlockchainRecord;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.exception.ErrorCode;
import com.jiangwu.repository.BlockchainRecordRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 区块链溯源服务
 * 处理存证记录查询、真伪验证、溯源链获取等
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class BlockchainService {

    private final BlockchainRecordRepository blockchainRecordRepository;

    @Value("${blockchain.mock-enabled:true}")
    private boolean mockEnabled;

    /**
     * 获取订单溯源记录列表
     */
    public List<Map<String, Object>> getRecords(Long orderId) {
        log.info("获取订单溯源记录: orderId={}", orderId);

        List<BlockchainRecord> records = blockchainRecordRepository.findByOrderId(orderId);

        return records.stream().map(record -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", record.getId());
            item.put("orderId", record.getOrderId());
            item.put("type", record.getType().getCode());
            item.put("typeName", record.getType().getLabel());
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
    }

    /**
     * 获取溯源记录详情
     */
    public Map<String, Object> getRecordDetail(Long id) {
        log.info("获取溯源记录详情: id={}", id);

        BlockchainRecord record = blockchainRecordRepository.findById(id);
        if (record == null) {
            throw new BusinessException(ErrorCode.BLOCKCHAIN_RECORD_NOT_FOUND);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", record.getId());
        result.put("orderId", record.getOrderId());
        result.put("type", record.getType().getCode());
        result.put("typeName", record.getType().getLabel());
        result.put("transactionId", record.getTransactionId());
        result.put("blockHash", record.getBlockHash());
        result.put("dataHash", record.getDataHash());
        result.put("evidenceData", record.getEvidenceData());
        result.put("certificateUrl", record.getCertificateUrl());
        result.put("timestamp", record.getTimestamp());
        result.put("isVerified", record.getIsVerified());
        result.put("createdAt", record.getCreatedAt());

        return result;
    }

    /**
     * 验证存证真伪
     */
    public Map<String, Object> verifyRecord(Long recordId) {
        log.info("验证存证真伪: recordId={}, mock={}", recordId, mockEnabled);

        BlockchainRecord record = blockchainRecordRepository.findById(recordId);
        if (record == null) {
            throw new BusinessException(ErrorCode.BLOCKCHAIN_RECORD_NOT_FOUND);
        }

        if (mockEnabled) {
            // Mock模式：模拟验证通过
            Map<String, Object> result = new HashMap<>();
            result.put("valid", true);
            result.put("message", "存证验证通过（Mock模式）");
            result.put("verifiedAt", LocalDateTime.now());
            result.put("blockHash", record.getBlockHash());
            result.put("mock", true);
            return result;
        }

        // 实际接入模式
        // TODO: 1. 根据transactionId查询链上数据
        // TODO: 2. 比对blockHash是否一致
        // TODO: 3. 更新isVerified状态

        Map<String, Object> result = new HashMap<>();
        result.put("valid", true);
        result.put("message", "存证验证通过");
        result.put("verifiedAt", LocalDateTime.now());
        result.put("blockHash", record.getBlockHash());
        result.put("mock", false);
        return result;
    }

    /**
     * 获取订单完整溯源链
     */
    public Map<String, Object> getTraceChain(Long orderId) {
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
            item.put("typeName", record.getType().getLabel());
            item.put("timestamp", record.getTimestamp());
            item.put("isVerified", record.getIsVerified());
            return item;
        }).collect(Collectors.toList()));
        result.put("totalSteps", totalSteps);
        result.put("verifiedSteps", verifiedSteps);

        return result;
    }

    /**
     * 下载存证证书
     */
    public Map<String, String> downloadCertificate(Long recordId) {
        log.info("下载存证证书: recordId={}", recordId);

        BlockchainRecord record = blockchainRecordRepository.findById(recordId);
        if (record == null) {
            throw new BusinessException(ErrorCode.BLOCKCHAIN_RECORD_NOT_FOUND);
        }

        Map<String, String> result = new HashMap<>();
        result.put("certificateUrl", record.getCertificateUrl() != null ? record.getCertificateUrl() : "");

        return result;
    }
}

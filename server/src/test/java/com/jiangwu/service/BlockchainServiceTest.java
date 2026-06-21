package com.jiangwu.service;

import com.jiangwu.entity.BlockchainRecord;
import com.jiangwu.enums.BlockchainType;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.repository.BlockchainRecordRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BlockchainServiceTest {

    @Mock private BlockchainRecordRepository blockchainRecordRepository;
    @InjectMocks private BlockchainService blockchainService;

    private BlockchainRecord testRecord;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(blockchainService, "mockEnabled", true);

        testRecord = new BlockchainRecord();
        testRecord.setId(1L);
        testRecord.setOrderId(100L);
        testRecord.setType(BlockchainType.ORDER_CREATED);
        testRecord.setTransactionId("tx_abc123");
        testRecord.setBlockHash("hash_def456");
        testRecord.setDataHash("data_hash_789");
        testRecord.setCertificateUrl("https://cert.example.com/1");
        testRecord.setTimestamp(LocalDateTime.now());
        testRecord.setIsVerified(true);
        testRecord.setCreatedAt(LocalDateTime.now());
    }

    // ==================== 获取记录列表 ====================

    @Test
    void getRecords_ReturnsList() {
        when(blockchainRecordRepository.findByOrderId(100L)).thenReturn(List.of(testRecord));

        List<Map<String, Object>> result = blockchainService.getRecords(100L);

        assertEquals(1, result.size());
        assertEquals("order_created", result.get(0).get("type"));
        assertEquals("tx_abc123", result.get(0).get("transactionId"));
    }

    @Test
    void getRecords_EmptyForNewOrder() {
        when(blockchainRecordRepository.findByOrderId(999L)).thenReturn(List.of());

        List<Map<String, Object>> result = blockchainService.getRecords(999L);

        assertTrue(result.isEmpty());
    }

    // ==================== 获取记录详情 ====================

    @Test
    void getRecordDetail_Success() {
        when(blockchainRecordRepository.findById(1L)).thenReturn(testRecord);

        Map<String, Object> result = blockchainService.getRecordDetail(1L);

        assertEquals(1L, result.get("id"));
        assertEquals(100L, result.get("orderId"));
        assertEquals("order_created", result.get("type"));
        assertEquals("订单创建", result.get("typeName"));
        assertTrue((Boolean) result.get("isVerified"));
    }

    @Test
    void getRecordDetail_NotFound_ThrowsException() {
        when(blockchainRecordRepository.findById(999L)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> blockchainService.getRecordDetail(999L));
    }

    // ==================== 验证存证真伪 ====================

    @Test
    void verifyRecord_MockMode_ReturnsValid() {
        when(blockchainRecordRepository.findById(1L)).thenReturn(testRecord);

        Map<String, Object> result = blockchainService.verifyRecord(1L);

        assertTrue((Boolean) result.get("valid"));
        assertTrue((Boolean) result.get("mock"));
        assertEquals("存证验证通过（Mock模式）", result.get("message"));
    }

    @Test
    void verifyRecord_NotFound_ThrowsException() {
        when(blockchainRecordRepository.findById(999L)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> blockchainService.verifyRecord(999L));
    }

    @Test
    void verifyRecord_NonMockMode_ReturnsValid() {
        ReflectionTestUtils.setField(blockchainService, "mockEnabled", false);
        when(blockchainRecordRepository.findById(1L)).thenReturn(testRecord);

        Map<String, Object> result = blockchainService.verifyRecord(1L);

        assertTrue((Boolean) result.get("valid"));
        assertFalse((Boolean) result.get("mock"));
    }

    // ==================== 获取溯源链 ====================

    @Test
    void getTraceChain_ReturnsCompleteChain() {
        BlockchainRecord record2 = new BlockchainRecord();
        record2.setId(2L);
        record2.setType(BlockchainType.STAGE_DELIVERED);
        record2.setTimestamp(LocalDateTime.now());
        record2.setIsVerified(false);

        when(blockchainRecordRepository.findByOrderId(100L)).thenReturn(List.of(testRecord, record2));

        Map<String, Object> result = blockchainService.getTraceChain(100L);

        assertEquals(100L, result.get("orderId"));
        assertEquals(2, result.get("totalSteps"));
        assertEquals(1, result.get("verifiedSteps"));
        List<Map<String, Object>> records = (List<Map<String, Object>>) result.get("records");
        assertEquals(2, records.size());
    }

    @Test
    void getTraceChain_EmptyChain() {
        when(blockchainRecordRepository.findByOrderId(999L)).thenReturn(List.of());

        Map<String, Object> result = blockchainService.getTraceChain(999L);

        assertEquals(0, result.get("totalSteps"));
        assertEquals(0, result.get("verifiedSteps"));
    }

    // ==================== 下载证书 ====================

    @Test
    void downloadCertificate_Success() {
        when(blockchainRecordRepository.findById(1L)).thenReturn(testRecord);

        Map<String, String> result = blockchainService.downloadCertificate(1L);

        assertEquals("https://cert.example.com/1", result.get("certificateUrl"));
    }

    @Test
    void downloadCertificate_NullUrl_ReturnsEmpty() {
        testRecord.setCertificateUrl(null);
        when(blockchainRecordRepository.findById(1L)).thenReturn(testRecord);

        Map<String, String> result = blockchainService.downloadCertificate(1L);

        assertEquals("", result.get("certificateUrl"));
    }

    @Test
    void downloadCertificate_NotFound_ThrowsException() {
        when(blockchainRecordRepository.findById(999L)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> blockchainService.downloadCertificate(999L));
    }
}

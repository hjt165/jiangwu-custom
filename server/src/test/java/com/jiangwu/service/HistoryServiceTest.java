package com.jiangwu.service;

import com.jiangwu.entity.BrowseHistory;
import com.jiangwu.repository.BrowseHistoryRepository;
import com.jiangwu.repository.ProductImageRepository;
import com.jiangwu.repository.ProductRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class HistoryServiceTest {

    @Mock private BrowseHistoryRepository historyRepository;
    @Mock private ProductRepository productRepository;
    @Mock private ProductImageRepository productImageRepository;
    @InjectMocks private HistoryService historyService;

    @Test
    void recordView_DeletesOldAndCreatesNew() {
        when(historyRepository.deleteByUserAndProduct(1L, 1L)).thenReturn(1);
        when(historyRepository.insert(any(BrowseHistory.class))).thenReturn(1);

        assertDoesNotThrow(() -> historyService.recordView(1L, 1L));
        verify(historyRepository).deleteByUserAndProduct(1L, 1L);
        verify(historyRepository).insert(any(BrowseHistory.class));
    }

    @Test
    void getHistoryList_Empty() {
        when(historyRepository.findProductIdsByUserId(1L)).thenReturn(List.of());
        var result = historyService.getHistoryList(1L);
        assertTrue(result.isEmpty());
    }

    @Test
    void clearHistory_DeletesAll() {
        when(historyRepository.clearByUserId(1L)).thenReturn(5);
        assertDoesNotThrow(() -> historyService.clearHistory(1L));
        verify(historyRepository).clearByUserId(1L);
    }

    @Test
    void getHistoryProductIds_ReturnsIds() {
        when(historyRepository.findProductIdsByUserId(1L)).thenReturn(List.of(1L, 2L, 3L));
        List<Long> result = historyService.getHistoryProductIds(1L);
        assertEquals(3, result.size());
    }
}

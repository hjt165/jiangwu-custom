package com.jiangwu.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangwu.entity.Feedback;
import com.jiangwu.repository.FeedbackRepository;
import org.junit.jupiter.api.BeforeEach;
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
class FeedbackServiceTest {

    @Mock private FeedbackRepository feedbackRepository;
    @InjectMocks private FeedbackService feedbackService;

    private Feedback testFeedback;

    @BeforeEach
    void setUp() {
        testFeedback = new Feedback();
        testFeedback.setId(1L);
        testFeedback.setUserId(100L);
        testFeedback.setContent("建议增加更多分类");
        testFeedback.setContact("test@example.com");
        testFeedback.setStatus(0);
    }

    @Test
    void submit_Success() {
        doReturn(1).when(feedbackRepository).insert(any(Feedback.class));

        Feedback result = feedbackService.submit(100L, "建议增加更多分类", "test@example.com");

        assertNotNull(result);
        assertEquals(100L, result.getUserId());
        assertEquals("建议增加更多分类", result.getContent());
        assertEquals("test@example.com", result.getContact());
        assertEquals(0, result.getStatus());
        verify(feedbackRepository).insert(any(Feedback.class));
    }

    @Test
    void getList_ReturnsPaginatedResults() {
        Page<Feedback> page = new Page<>(1, 10);
        page.setRecords(List.of(testFeedback));
        page.setTotal(1);
        when(feedbackRepository.selectPage(any(Page.class), any(QueryWrapper.class))).thenReturn(page);

        List<Feedback> result = feedbackService.getList(1, 10);

        assertEquals(1, result.size());
        assertEquals("建议增加更多分类", result.get(0).getContent());
    }

    @Test
    void getList_EmptyPage() {
        Page<Feedback> page = new Page<>(1, 10);
        page.setRecords(List.of());
        page.setTotal(0);
        when(feedbackRepository.selectPage(any(Page.class), any(QueryWrapper.class))).thenReturn(page);

        List<Feedback> result = feedbackService.getList(1, 10);

        assertTrue(result.isEmpty());
    }

    @Test
    void getCount_ReturnsTotal() {
        when(feedbackRepository.selectCount(null)).thenReturn(25L);

        long count = feedbackService.getCount();

        assertEquals(25L, count);
    }

    @Test
    void getCount_ZeroWhenEmpty() {
        when(feedbackRepository.selectCount(null)).thenReturn(0L);

        long count = feedbackService.getCount();

        assertEquals(0L, count);
    }
}

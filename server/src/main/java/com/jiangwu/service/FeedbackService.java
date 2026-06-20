package com.jiangwu.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.jiangwu.entity.Feedback;
import com.jiangwu.repository.FeedbackRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 意见反馈服务
 */
@Service
@RequiredArgsConstructor
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;

    /**
     * 提交反馈
     */
    public Feedback submit(Long userId, String content, String contact) {
        Feedback feedback = new Feedback();
        feedback.setUserId(userId);
        feedback.setContent(content);
        feedback.setContact(contact);
        feedback.setStatus(0);
        feedbackRepository.insert(feedback);
        return feedback;
    }

    /**
     * 获取反馈列表（管理后台用）
     */
    public List<Feedback> getList(int page, int size) {
        QueryWrapper<Feedback> wrapper = new QueryWrapper<>();
        wrapper.orderByDesc("created_at");
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);
        return feedbackRepository.selectList(wrapper);
    }

    /**
     * 获取反馈总数
     */
    public long getCount() {
        return feedbackRepository.selectCount(null);
    }
}

package com.jiangwu.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.jiangwu.entity.Conversation;
import com.jiangwu.entity.Message;
import com.jiangwu.repository.ConversationRepository;
import com.jiangwu.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 聊天服务
 */
@Service
@RequiredArgsConstructor
public class ChatService {

    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;

    /**
     * 获取或创建会话
     */
    @Transactional
    public Conversation getOrCreateConversation(Long userId, Long artisanId, Long orderId) {
        Conversation conversation = conversationRepository.findByUserAndArtisan(userId, artisanId);
        if (conversation == null) {
            conversation = new Conversation();
            conversation.setUserId(userId);
            conversation.setArtisanId(artisanId);
            conversation.setOrderId(orderId);
            conversation.setUserUnread(0);
            conversation.setArtisanUnread(0);
            conversationRepository.insert(conversation);
        }
        return conversation;
    }

    /**
     * 获取用户会话列表
     */
    public List<Conversation> getUserConversations(Long userId) {
        return conversationRepository.findByUserId(userId);
    }

    /**
     * 获取手作人会话列表
     */
    public List<Conversation> getArtisanConversations(Long artisanId) {
        return conversationRepository.findByArtisanId(artisanId);
    }

    /**
     * 获取会话详情
     */
    public Conversation getConversation(Long conversationId) {
        return conversationRepository.findById(conversationId);
    }

    /**
     * 发送消息
     */
    @Transactional
    public Message sendMessage(Long conversationId, Long senderId, String content, String messageType) {
        // 保存消息
        Message message = new Message();
        message.setConversationId(conversationId);
        message.setSenderId(senderId);
        message.setContent(content);
        message.setMessageType(messageType != null ? messageType : "text");
        message.setStatus(1); // 已发送
        messageRepository.insert(message);

        // 更新会话最后消息
        String lastMessage = "text".equals(messageType) ? content : "[" + messageType + "]";
        conversationRepository.updateLastMessage(conversationId, lastMessage);

        // 增加未读数
        Conversation conversation = conversationRepository.findById(conversationId);
        if (conversation.getUserId().equals(senderId)) {
            conversationRepository.incrementArtisanUnread(conversationId);
        } else {
            conversationRepository.incrementUserUnread(conversationId);
        }

        return message;
    }

    /**
     * 获取会话消息列表
     */
    public List<Message> getMessages(Long conversationId, int limit) {
        return messageRepository.findByConversationId(conversationId, limit);
    }

    /**
     * 获取历史消息（分页）
     */
    public List<Message> getHistoryMessages(Long conversationId, LocalDateTime before, int limit) {
        return messageRepository.findByConversationIdBefore(conversationId, before, limit);
    }

    /**
     * 标记已读
     */
    @Transactional
    public void markAsRead(Long conversationId, Long userId) {
        messageRepository.markAsRead(conversationId, userId);

        Conversation conversation = conversationRepository.findById(conversationId);
        if (conversation.getUserId().equals(userId)) {
            conversationRepository.resetUserUnread(conversationId);
        } else {
            conversationRepository.resetArtisanUnread(conversationId);
        }
    }

    /**
     * 获取未读消息总数
     */
    public int getUnreadCount(Long userId, String role) {
        List<Conversation> conversations;
        if ("artisan".equals(role)) {
            conversations = conversationRepository.findByArtisanId(userId);
            return conversations.stream().mapToInt(Conversation::getArtisanUnread).sum();
        } else {
            conversations = conversationRepository.findByUserId(userId);
            return conversations.stream().mapToInt(Conversation::getUserUnread).sum();
        }
    }
}
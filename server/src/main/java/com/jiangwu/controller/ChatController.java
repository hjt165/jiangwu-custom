package com.jiangwu.controller;

import com.jiangwu.entity.Conversation;
import com.jiangwu.entity.Message;
import com.jiangwu.handler.ChatWebSocketHandler;
import com.jiangwu.service.ChatService;
import com.jiangwu.common.Result;
import com.jiangwu.utils.CurrentUserUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 聊天控制器
 */
@Tag(name = "聊天接口")
@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;
    private final ChatWebSocketHandler chatWebSocketHandler;
    private final CurrentUserUtil currentUserUtil;

    @Operation(summary = "获取或创建会话")
    @GetMapping("/conversation")
    public Result<Conversation> getOrCreateConversation(
            HttpServletRequest request,
            @RequestParam Long artisanId,
            @RequestParam(required = false) Long orderId) {
        Long userId = currentUserUtil.extractUserId(request);
        Conversation conversation = chatService.getOrCreateConversation(userId, artisanId, orderId);
        return Result.success(conversation);
    }

    @Operation(summary = "获取用户会话列表")
    @GetMapping("/conversations")
    public Result<List<Conversation>> getUserConversations(HttpServletRequest request) {
        Long userId = currentUserUtil.extractUserId(request);
        List<Conversation> conversations = chatService.getUserConversations(userId);
        return Result.success(conversations);
    }

    @Operation(summary = "获取会话消息列表")
    @GetMapping("/messages/{conversationId}")
    public Result<List<Message>> getMessages(
            @PathVariable Long conversationId,
            @RequestParam(defaultValue = "50") int limit) {
        List<Message> messages = chatService.getMessages(conversationId, limit);
        return Result.success(messages);
    }

    @Operation(summary = "获取历史消息（分页）")
    @GetMapping("/messages/{conversationId}/history")
    public Result<List<Message>> getHistoryMessages(
            @PathVariable Long conversationId,
            @RequestParam String before,
            @RequestParam(defaultValue = "50") int limit) {
        List<Message> messages = chatService.getHistoryMessages(
                conversationId,
                java.time.LocalDateTime.parse(before),
                limit
        );
        return Result.success(messages);
    }

    @Operation(summary = "标记已读")
    @PostMapping("/read/{conversationId}")
    public Result<Void> markAsRead(
            HttpServletRequest request,
            @PathVariable Long conversationId) {
        Long userId = currentUserUtil.extractUserId(request);
        chatService.markAsRead(conversationId, userId);
        return Result.success();
    }

    @Operation(summary = "获取未读消息数")
    @GetMapping("/unread")
    public Result<Map<String, Object>> getUnreadCount(
            HttpServletRequest request,
            @RequestParam(defaultValue = "user") String role) {
        Long userId = currentUserUtil.extractUserId(request);
        int count = chatService.getUnreadCount(userId, role);
        return Result.success(Map.of("unreadCount", count));
    }

    @Operation(summary = "发送消息（REST接口，备选方案）")
    @PostMapping("/send")
    public Result<Message> sendMessage(
            HttpServletRequest request,
            @RequestBody Map<String, Object> requestBody) {
        Long senderId = currentUserUtil.extractUserId(request);
        Long conversationId = Long.valueOf(requestBody.get("conversationId").toString());
        String content = (String) requestBody.get("content");
        String messageType = (String) requestBody.getOrDefault("messageType", "text");

        Message message = chatService.sendMessage(conversationId, senderId, content, messageType);

        // 通过WebSocket推送
        var conversation = chatService.getConversation(conversationId);
        Long receiverId = conversation.getUserId().equals(senderId)
                ? conversation.getArtisanId()
                : conversation.getUserId();

        chatWebSocketHandler.sendToUser(receiverId, Map.of(
                "type", "chat",
                "messageId", message.getId(),
                "conversationId", conversationId,
                "senderId", senderId,
                "content", content,
                "messageType", messageType,
                "createdAt", message.getCreatedAt().toString()
        ));

        return Result.success(message);
    }
}
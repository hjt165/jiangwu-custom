package com.jiangwu.handler;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jiangwu.entity.Message;
import com.jiangwu.service.ChatService;
import com.jiangwu.utils.JWTUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 聊天WebSocket处理器
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private final ChatService chatService;
    private final ObjectMapper objectMapper;
    private final JWTUtil jwtUtil;

    // userId -> WebSocketSession
    private final ConcurrentHashMap<Long, WebSocketSession> sessions = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        Long userId = getUserIdFromSession(session);
        if (userId != null) {
            sessions.put(userId, session);
            log.info("用户 {} 已连接WebSocket", userId);
        } else {
            log.warn("WebSocket连接认证失败，关闭连接");
            session.close(CloseStatus.POLICY_VIOLATION);
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        Long userId = getUserIdFromSession(session);
        if (userId != null) {
            sessions.remove(userId);
            log.info("用户 {} 已断开WebSocket", userId);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        try {
            Map<String, Object> payload = objectMapper.readValue(message.getPayload(), Map.class);
            String type = (String) payload.get("type");

            switch (type) {
                case "chat":
                    handleChatMessage(session, payload);
                    break;
                case "read":
                    handleReadMessage(session, payload);
                    break;
                case "ping":
                    handlePingMessage(session);
                    break;
                default:
                    log.warn("未知消息类型: {}", type);
            }
        } catch (Exception e) {
            log.error("处理WebSocket消息失败", e);
            sendMessage(session, Map.of("type", "error", "message", "消息处理失败"));
        }
    }

    private void handleChatMessage(WebSocketSession session, Map<String, Object> payload) throws Exception {
        Long senderId = getUserIdFromSession(session);
        Long conversationId = Long.valueOf(payload.get("conversationId").toString());
        String content = (String) payload.get("content");
        String messageType = payload.getOrDefault("messageType", "text").toString();

        Message savedMessage = chatService.sendMessage(conversationId, senderId, content, messageType);

        // 获取会话信息，确定接收方
        var conversation = chatService.getConversation(conversationId);
        Long receiverId = conversation.getUserId().equals(senderId)
                ? conversation.getArtisanId()
                : conversation.getUserId();

        // 发送给接收方
        Map<String, Object> response = Map.of(
                "type", "chat",
                "messageId", savedMessage.getId(),
                "conversationId", conversationId,
                "senderId", senderId,
                "content", content,
                "messageType", messageType,
                "createdAt", savedMessage.getCreatedAt().toString()
        );

        sendToUser(receiverId, response);

        // 回显给发送方
        Map<String, Object> echo = Map.of(
                "type", "chat_echo",
                "messageId", savedMessage.getId(),
                "conversationId", conversationId,
                "content", content,
                "messageType", messageType,
                "createdAt", savedMessage.getCreatedAt().toString()
        );
        sendMessage(session, echo);
    }

    private void handleReadMessage(WebSocketSession session, Map<String, Object> payload) throws Exception {
        Long userId = getUserIdFromSession(session);
        Long conversationId = Long.valueOf(payload.get("conversationId").toString());

        chatService.markAsRead(conversationId, userId);

        // 通知对方已读
        var conversation = chatService.getConversation(conversationId);
        Long receiverId = conversation.getUserId().equals(userId)
                ? conversation.getArtisanId()
                : conversation.getUserId();

        sendToUser(receiverId, Map.of(
                "type", "read",
                "conversationId", conversationId,
                "userId", userId
        ));
    }

    private void handlePingMessage(WebSocketSession session) throws Exception {
        sendMessage(session, Map.of("type", "pong"));
    }

    private Long getUserIdFromSession(WebSocketSession session) {
        try {
            var uri = session.getUri();
            if (uri != null) {
                var params = UriComponentsBuilder.fromUri(uri).build().getQueryParams();
                // 优先使用 token 鉴权
                var token = params.getFirst("token");
                if (token != null && jwtUtil.validateToken(token)) {
                    return jwtUtil.parseUserId(token);
                }
                // token 无效则拒绝连接
                log.warn("WebSocket连接缺少有效token，拒绝连接");
                return null;
            }
            // 从session attributes获取（仅当已通过HandshakeInterceptor设置时）
            var attrs = session.getAttributes();
            if (attrs.containsKey("userId")) {
                return (Long) attrs.get("userId");
            }
        } catch (Exception e) {
            log.error("获取用户ID失败", e);
        }
        return null;
    }

    public void sendToUser(Long userId, Map<String, Object> message) {
        WebSocketSession session = sessions.get(userId);
        if (session != null && session.isOpen()) {
            sendMessage(session, message);
        }
    }

    private void sendMessage(WebSocketSession session, Map<String, Object> message) {
        try {
            String json = objectMapper.writeValueAsString(message);
            session.sendMessage(new TextMessage(json));
        } catch (IOException e) {
            log.error("发送WebSocket消息失败", e);
        }
    }

    public boolean isUserOnline(Long userId) {
        WebSocketSession session = sessions.get(userId);
        return session != null && session.isOpen();
    }
}
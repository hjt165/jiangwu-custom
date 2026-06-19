package com.jiangwu.controller;

import com.jiangwu.entity.Conversation;
import com.jiangwu.entity.Message;
import com.jiangwu.handler.ChatWebSocketHandler;
import com.jiangwu.exception.GlobalExceptionHandler;
import com.jiangwu.service.ChatService;
import com.jiangwu.utils.CurrentUserUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 聊天控制器测试
 */
class ChatControllerTest {

    private MockMvc mockMvc;
    private ChatService chatService;
    private ChatWebSocketHandler chatWebSocketHandler;
    private CurrentUserUtil currentUserUtil;

    @BeforeEach
    void setUp() {
        chatService = mock(ChatService.class);
        chatWebSocketHandler = mock(ChatWebSocketHandler.class);
        currentUserUtil = mock(CurrentUserUtil.class);

        ChatController controller = new ChatController(chatService, chatWebSocketHandler, currentUserUtil);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void getOrCreateConversation_Success() throws Exception {
        Conversation conversation = new Conversation();
        conversation.setId(1L);
        conversation.setUserId(1L);
        conversation.setArtisanId(2L);

        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(chatService.getOrCreateConversation(anyLong(), anyLong(), any())).thenReturn(conversation);

        mockMvc.perform(get("/chat/conversation")
                        .header("Authorization", "Bearer test_token")
                        .param("artisanId", "2"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void getConversations_Success() throws Exception {
        Conversation conversation = new Conversation();
        conversation.setId(1L);
        conversation.setLastMessage("你好");

        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(chatService.getUserConversations(anyLong())).thenReturn(List.of(conversation));

        mockMvc.perform(get("/chat/conversations")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void getMessages_Success() throws Exception {
        Message message = new Message();
        message.setId(1L);
        message.setContent("测试消息");
        message.setSenderId(1L);
        message.setCreatedAt(LocalDateTime.now());

        when(chatService.getMessages(anyLong(), anyInt()))
                .thenReturn(List.of(message));

        mockMvc.perform(get("/chat/messages/1")
                        .header("Authorization", "Bearer test_token")
                        .param("limit", "20"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void sendMessage_Success() throws Exception {
        Message message = new Message();
        message.setId(1L);
        message.setContent("你好");
        message.setSenderId(1L);
        message.setCreatedAt(LocalDateTime.now());

        Conversation conversation = new Conversation();
        conversation.setId(1L);
        conversation.setUserId(1L);
        conversation.setArtisanId(2L);

        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(chatService.sendMessage(anyLong(), anyLong(), anyString(), anyString()))
                .thenReturn(message);
        when(chatService.getConversation(anyLong())).thenReturn(conversation);

        mockMvc.perform(post("/chat/send")
                        .header("Authorization", "Bearer test_token")
                        .contentType("application/json")
                        .content("{\"conversationId\": 1, \"content\": \"你好\", \"messageType\": \"text\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void markAsRead_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);

        mockMvc.perform(post("/chat/read/1")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void getUnreadCount_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(chatService.getUnreadCount(anyLong(), anyString())).thenReturn(5);

        mockMvc.perform(get("/chat/unread")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.unreadCount").value(5));
    }
}

package com.jiangwu.service;

import com.jiangwu.entity.Conversation;
import com.jiangwu.entity.Message;
import com.jiangwu.repository.ConversationRepository;
import com.jiangwu.repository.MessageRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ChatServiceTest {

    @Mock private ConversationRepository conversationRepository;
    @Mock private MessageRepository messageRepository;
    @InjectMocks private ChatService chatService;

    private Conversation testConversation;

    @BeforeEach
    void setUp() {
        testConversation = new Conversation();
        testConversation.setId(1L);
        testConversation.setUserId(1L);
        testConversation.setArtisanId(2L);
        testConversation.setOrderId(1L);
        testConversation.setUserUnread(0);
        testConversation.setArtisanUnread(0);
    }

    @Test
    void getOrCreateConversation_NewConversation_CreatesAndReturns() {
        when(conversationRepository.findByUserAndArtisan(1L, 2L)).thenReturn(null);
        when(conversationRepository.insert(any(Conversation.class))).thenReturn(1);

        Conversation result = chatService.getOrCreateConversation(1L, 2L, 1L);

        assertNotNull(result);
        assertEquals(1L, result.getUserId());
        assertEquals(2L, result.getArtisanId());
        verify(conversationRepository).insert(any(Conversation.class));
    }

    @Test
    void getOrCreateConversation_ExistingConversation_ReturnsExisting() {
        when(conversationRepository.findByUserAndArtisan(1L, 2L)).thenReturn(testConversation);

        Conversation result = chatService.getOrCreateConversation(1L, 2L, 1L);

        assertEquals(1L, result.getId());
        verify(conversationRepository, never()).insert(any(Conversation.class));
    }

    @Test
    void sendMessage_TextMessage_UpdatesLastMessageAndIncrementsUnread() {
        when(messageRepository.insert(any(Message.class))).thenReturn(1);
        when(conversationRepository.updateLastMessage(1L, "你好")).thenReturn(1);
        when(conversationRepository.findById(1L)).thenReturn(testConversation);

        Message result = chatService.sendMessage(1L, 1L, "你好", "text");

        assertNotNull(result);
        assertEquals("你好", result.getContent());
        assertEquals("text", result.getMessageType());
        verify(conversationRepository).updateLastMessage(1L, "你好");
        verify(conversationRepository).incrementArtisanUnread(1L);
    }

    @Test
    void sendMessage_ImageMessage_FormatsBracketNotation() {
        when(messageRepository.insert(any(Message.class))).thenReturn(1);
        when(conversationRepository.updateLastMessage(1L, "[image]")).thenReturn(1);
        when(conversationRepository.findById(1L)).thenReturn(testConversation);

        chatService.sendMessage(1L, 1L, "base64data", "image");

        verify(conversationRepository).updateLastMessage(1L, "[image]");
    }

    @Test
    void sendMessage_ArtisanSender_IncrementsUserUnread() {
        when(messageRepository.insert(any(Message.class))).thenReturn(1);
        when(conversationRepository.updateLastMessage(1L, "回复内容")).thenReturn(1);
        when(conversationRepository.findById(1L)).thenReturn(testConversation);

        chatService.sendMessage(1L, 2L, "回复内容", "text");

        verify(conversationRepository).incrementUserUnread(1L);
        verify(conversationRepository, never()).incrementArtisanUnread(anyLong());
    }

    @Test
    void sendMessage_NullMessageType_FormatsAsBracketNull() {
        // 当 messageType 为 null 时，代码执行 "[" + messageType + "]" = "[null]"
        when(messageRepository.insert(any(Message.class))).thenReturn(1);
        when(conversationRepository.updateLastMessage(1L, "[null]")).thenReturn(1);
        when(conversationRepository.findById(1L)).thenReturn(testConversation);

        Message result = chatService.sendMessage(1L, 1L, "内容", null);

        assertEquals("text", result.getMessageType());
        verify(conversationRepository).updateLastMessage(1L, "[null]");
    }

    @Test
    void markAsRead_UserMarksResetsUserUnread() {
        when(messageRepository.markAsRead(1L, 1L)).thenReturn(1);
        when(conversationRepository.findById(1L)).thenReturn(testConversation);

        chatService.markAsRead(1L, 1L);

        verify(conversationRepository).resetUserUnread(1L);
        verify(conversationRepository, never()).resetArtisanUnread(anyLong());
    }

    @Test
    void markAsRead_ArtisanMarksResetsArtisanUnread() {
        when(messageRepository.markAsRead(1L, 2L)).thenReturn(1);
        when(conversationRepository.findById(1L)).thenReturn(testConversation);

        chatService.markAsRead(1L, 2L);

        verify(conversationRepository).resetArtisanUnread(1L);
        verify(conversationRepository, never()).resetUserUnread(anyLong());
    }

    @Test
    void getUnreadCount_UserRole_SumsUserUnread() {
        Conversation c1 = new Conversation();
        c1.setUserUnread(3);
        c1.setArtisanUnread(0);
        Conversation c2 = new Conversation();
        c2.setUserUnread(5);
        c2.setArtisanUnread(0);
        when(conversationRepository.findByUserId(1L)).thenReturn(List.of(c1, c2));

        int count = chatService.getUnreadCount(1L, "user");

        assertEquals(8, count);
    }

    @Test
    void getUnreadCount_ArtisanRole_SumsArtisanUnread() {
        Conversation c1 = new Conversation();
        c1.setUserUnread(0);
        c1.setArtisanUnread(2);
        when(conversationRepository.findByArtisanId(2L)).thenReturn(List.of(c1));

        int count = chatService.getUnreadCount(2L, "artisan");

        assertEquals(2, count);
    }

    @Test
    void getMessages_ReturnsMessageList() {
        Message msg = new Message();
        msg.setContent("hello");
        when(messageRepository.findByConversationId(1L, 20)).thenReturn(List.of(msg));

        List<Message> result = chatService.getMessages(1L, 20);

        assertEquals(1, result.size());
        assertEquals("hello", result.get(0).getContent());
    }

    @Test
    void getHistoryMessages_ReturnsBeforeTimestamp() {
        LocalDateTime before = LocalDateTime.now();
        when(messageRepository.findByConversationIdBefore(1L, before, 10)).thenReturn(List.of());

        List<Message> result = chatService.getHistoryMessages(1L, before, 10);

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }
}

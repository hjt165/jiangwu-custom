package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.Conversation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface ConversationRepository extends BaseMapper<Conversation> {

    @Select("SELECT * FROM t_conversation WHERE id = #{id}")
    Conversation findById(Long id);

    @Select("SELECT * FROM t_conversation WHERE user_id = #{userId} ORDER BY last_message_at DESC")
    List<Conversation> findByUserId(Long userId);

    @Select("SELECT * FROM t_conversation WHERE artisan_id = #{artisanId} ORDER BY last_message_at DESC")
    List<Conversation> findByArtisanId(Long artisanId);

    @Select("SELECT * FROM t_conversation WHERE user_id = #{userId} AND artisan_id = #{artisanId}")
    Conversation findByUserAndArtisan(Long userId, Long artisanId);

    @Update("UPDATE t_conversation SET last_message = #{lastMessage}, last_message_at = NOW(), updated_at = NOW() WHERE id = #{id}")
    int updateLastMessage(Long id, String lastMessage);

    @Update("UPDATE t_conversation SET user_unread = user_unread + 1, updated_at = NOW() WHERE id = #{id}")
    int incrementUserUnread(Long id);

    @Update("UPDATE t_conversation SET artisan_unread = artisan_unread + 1, updated_at = NOW() WHERE id = #{id}")
    int incrementArtisanUnread(Long id);

    @Update("UPDATE t_conversation SET user_unread = 0, updated_at = NOW() WHERE id = #{id}")
    int resetUserUnread(Long id);

    @Update("UPDATE t_conversation SET artisan_unread = 0, updated_at = NOW() WHERE id = #{id}")
    int resetArtisanUnread(Long id);
}
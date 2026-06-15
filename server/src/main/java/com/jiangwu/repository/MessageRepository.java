package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.Message;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface MessageRepository extends BaseMapper<Message> {

    @Select("SELECT * FROM t_message WHERE id = #{id}")
    Message findById(Long id);

    @Select("SELECT * FROM t_message WHERE conversation_id = #{conversationId} ORDER BY created_at DESC LIMIT #{limit}")
    List<Message> findByConversationId(Long conversationId, int limit);

    @Select("SELECT * FROM t_message WHERE conversation_id = #{conversationId} AND created_at < #{before} ORDER BY created_at DESC LIMIT #{limit}")
    List<Message> findByConversationIdBefore(Long conversationId, java.time.LocalDateTime before, int limit);

    @Update("UPDATE t_message SET status = #{status} WHERE id = #{id}")
    int updateStatus(Long id, Integer status);

    @Update("UPDATE t_message SET status = 2 WHERE conversation_id = #{conversationId} AND sender_id != #{userId}")
    int markAsRead(Long conversationId, Long userId);
}
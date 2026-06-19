package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.Review;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface ReviewRepository extends BaseMapper<Review> {

    @Select("SELECT * FROM t_review WHERE id = #{id} AND deleted = 0")
    Review findById(Long id);

    @Select("SELECT * FROM t_review WHERE order_id = #{orderId} AND deleted = 0")
    Review findByOrderId(Long orderId);

    @Select("SELECT * FROM t_review WHERE artisan_id = #{artisanId} AND deleted = 0 ORDER BY created_at DESC")
    List<Review> findByArtisanId(Long artisanId);

    @Select("SELECT * FROM t_review WHERE order_id IN (SELECT id FROM t_order WHERE product_id = #{productId}) AND deleted = 0")
    List<Review> findByProductId(Long productId);

    @Select("SELECT * FROM t_review WHERE user_id = #{userId} AND deleted = 0 ORDER BY created_at DESC")
    List<Review> findByUserId(Long userId);

    @Update("UPDATE t_review SET reply = #{reply}, reply_at = NOW(), updated_at = NOW() WHERE id = #{id}")
    int updateReply(Long id, String reply);
}

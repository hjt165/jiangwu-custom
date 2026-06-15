package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.UserFavorite;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Delete;

import java.util.List;

@Mapper
public interface UserFavoriteRepository extends BaseMapper<UserFavorite> {

    @Select("SELECT * FROM t_user_favorite WHERE user_id = #{userId} AND product_id = #{productId}")
    UserFavorite findByUserAndProduct(Long userId, Long productId);

    @Select("SELECT * FROM t_user_favorite WHERE user_id = #{userId} ORDER BY created_at DESC")
    List<UserFavorite> findByUserId(Long userId);

    @Select("SELECT product_id FROM t_user_favorite WHERE user_id = #{userId} ORDER BY created_at DESC")
    List<Long> findProductIdsByUserId(Long userId);

    @Delete("DELETE FROM t_user_favorite WHERE user_id = #{userId} AND product_id = #{productId}")
    int deleteByUserAndProduct(Long userId, Long productId);

    @Select("SELECT COUNT(*) FROM t_user_favorite WHERE product_id = #{productId}")
    int countByProductId(Long productId);
}

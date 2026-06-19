package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.UserFollow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface UserFollowRepository extends BaseMapper<UserFollow> {

    @Select("SELECT * FROM t_user_follow WHERE user_id = #{userId} ORDER BY created_at DESC")
    List<UserFollow> findByUserId(Long userId);

    @Select("SELECT * FROM t_user_follow WHERE artisan_id = #{artisanId} ORDER BY created_at DESC")
    List<UserFollow> findByArtisanId(Long artisanId);

    @Select("SELECT * FROM t_user_follow WHERE user_id = #{userId} AND artisan_id = #{artisanId}")
    UserFollow findByUserIdAndArtisanId(Long userId, Long artisanId);
}

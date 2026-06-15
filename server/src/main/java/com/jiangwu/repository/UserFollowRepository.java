package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.UserFollow;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface UserFollowRepository extends BaseMapper<UserFollow> {

    List<UserFollow> findByUserId(Long userId);

    List<UserFollow> findByArtisanId(Long artisanId);

    UserFollow findByUserIdAndArtisanId(Long userId, Long artisanId);
}

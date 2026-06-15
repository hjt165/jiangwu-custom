package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.BrowseHistory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface BrowseHistoryRepository extends BaseMapper<BrowseHistory> {

    @Select("SELECT * FROM t_browse_history WHERE user_id = #{userId} AND product_id = #{productId}")
    BrowseHistory findByUserAndProduct(Long userId, Long productId);

    @Select("SELECT * FROM t_browse_history WHERE user_id = #{userId} ORDER BY created_at DESC")
    List<BrowseHistory> findByUserId(Long userId);

    @Select("SELECT product_id FROM t_browse_history WHERE user_id = #{userId} ORDER BY created_at DESC")
    List<Long> findProductIdsByUserId(Long userId);

    @Delete("DELETE FROM t_browse_history WHERE user_id = #{userId}")
    int clearByUserId(Long userId);

    @Delete("DELETE FROM t_browse_history WHERE user_id = #{userId} AND product_id = #{productId}")
    int deleteByUserAndProduct(Long userId, Long productId);
}

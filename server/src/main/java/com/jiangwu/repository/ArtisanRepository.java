package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.Artisan;
import com.jiangwu.enums.ArtisanStatus;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface ArtisanRepository extends BaseMapper<Artisan> {

    @Select("SELECT * FROM t_artisan WHERE user_id = #{userId} AND deleted = 0")
    Artisan findByUserId(Long userId);

    @Select("SELECT * FROM t_artisan WHERE id = #{id} AND deleted = 0")
    Artisan findById(Long id);

    @Select("SELECT * FROM t_artisan WHERE status = #{status} AND deleted = 0 ORDER BY rating DESC")
    List<Artisan> findByStatus(ArtisanStatus status);

    @Select("SELECT * FROM t_artisan WHERE deleted = 0 AND (specialty LIKE CONCAT('%', #{keyword}, '%') OR name LIKE CONCAT('%', #{keyword}, '%'))")
    List<Artisan> search(String keyword);

    @Update("UPDATE t_artisan SET status = #{status}, approved_at = #{approvedAt}, updated_at = NOW() WHERE id = #{id}")
    int updateStatus(Long id, ArtisanStatus status, LocalDateTime approvedAt);

    @Update("UPDATE t_artisan SET rating = #{rating}, order_count = order_count + 1, updated_at = NOW() WHERE id = #{id}")
    int updateRating(Long id, BigDecimal rating);

    @Update("UPDATE t_artisan SET fan_count = fan_count + #{delta}, updated_at = NOW() WHERE id = #{id}")
    int updateFanCount(Long id, int delta);
}

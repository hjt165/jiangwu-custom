package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.Order;
import com.jiangwu.enums.OrderStatus;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface OrderRepository extends BaseMapper<Order> {

    @Select("SELECT * FROM t_order WHERE id = #{id} AND deleted = 0")
    Order findById(Long id);

    @Select("SELECT * FROM t_order WHERE order_no = #{orderNo} AND deleted = 0")
    Order findByOrderNo(String orderNo);

    @Select("SELECT * FROM t_order WHERE user_id = #{userId} AND deleted = 0 ORDER BY created_at DESC")
    List<Order> findByUserId(Long userId);

    @Select("SELECT * FROM t_order WHERE artisan_id = #{artisanId} AND deleted = 0 ORDER BY created_at DESC")
    List<Order> findByArtisanId(Long artisanId);

    @Select("SELECT * FROM t_order WHERE user_id = #{userId} AND status = #{status} AND deleted = 0 ORDER BY created_at DESC")
    List<Order> findByUserIdAndStatus(Long userId, OrderStatus status);

    @Update("UPDATE t_order SET status = #{status}, updated_at = NOW() WHERE id = #{id}")
    int updateStatus(Long id, OrderStatus status);

    @Update("UPDATE t_order SET status = #{status}, paid_at = #{paidAt}, paid_amount = #{paidAmount}, updated_at = NOW() WHERE id = #{id}")
    int updatePaid(Long id, OrderStatus status, LocalDateTime paidAt, java.math.BigDecimal paidAmount);

    @Update("UPDATE t_order SET status = #{status}, completed_at = #{completedAt}, updated_at = NOW() WHERE id = #{id}")
    int updateCompleted(Long id, OrderStatus status, LocalDateTime completedAt);

    @Update("UPDATE t_order SET status = #{status}, cancelled_at = #{cancelledAt}, cancel_reason = #{reason}, updated_at = NOW() WHERE id = #{id}")
    int updateCancelled(Long id, OrderStatus status, LocalDateTime cancelledAt, String reason);

    @Update("UPDATE t_order SET current_stage = #{stage}, updated_at = NOW() WHERE id = #{id}")
    int updateCurrentStage(Long id, int stage);
}

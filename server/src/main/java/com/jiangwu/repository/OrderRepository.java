package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangwu.entity.Order;
import com.jiangwu.enums.OrderStatus;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.math.BigDecimal;
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

    // ========== SQL 聚合查询（避免全表加载到内存） ==========

    @Select("SELECT COALESCE(SUM(total_amount), 0) FROM t_order WHERE status = 'completed' AND deleted = 0")
    BigDecimal sumCompletedRevenue();

    @Select("SELECT COALESCE(SUM(total_amount), 0) FROM t_order WHERE status = 'completed' AND deleted = 0 AND created_at >= #{startDate}")
    BigDecimal sumCompletedRevenueFrom(java.time.LocalDateTime startDate);

    @Update("UPDATE t_order SET status = #{status}, updated_at = NOW() WHERE id = #{id}")
    int updateStatus(Long id, OrderStatus status);

    @Update("UPDATE t_order SET status = #{status}, paid_at = #{paidAt}, paid_amount = #{paidAmount}, updated_at = NOW() WHERE id = #{id}")
    int updatePaid(Long id, OrderStatus status, LocalDateTime paidAt, BigDecimal paidAmount);

    @Update("UPDATE t_order SET status = #{status}, completed_at = #{completedAt}, updated_at = NOW() WHERE id = #{id}")
    int updateCompleted(Long id, OrderStatus status, LocalDateTime completedAt);

    @Update("UPDATE t_order SET status = #{status}, cancelled_at = #{cancelledAt}, cancel_reason = #{reason}, updated_at = NOW() WHERE id = #{id}")
    int updateCancelled(Long id, OrderStatus status, LocalDateTime cancelledAt, String reason);

    @Update("UPDATE t_order SET current_stage = #{stage}, updated_at = NOW() WHERE id = #{id}")
    int updateCurrentStage(Long id, int stage);

    // ========== 手作人端 SQL 聚合查询（避免全表加载到内存） ==========

    @Select("SELECT COUNT(*) FROM t_order WHERE artisan_id = #{artisanId} AND status IN ('PAID', 'PENDING_PAYMENT') AND deleted = 0")
    long countPendingOrdersByArtisanId(Long artisanId);

    @Select("SELECT COUNT(*) FROM t_order WHERE artisan_id = #{artisanId} AND deleted = 0 AND DATE(created_at) = CURDATE()")
    long countTodayOrdersByArtisanId(Long artisanId);

    @Select("SELECT COALESCE(SUM(total_amount), 0) FROM t_order WHERE artisan_id = #{artisanId} AND status = 'COMPLETED' AND deleted = 0 AND completed_at >= #{startDate}")
    BigDecimal sumCompletedIncomeByArtisanId(Long artisanId, LocalDateTime startDate);

    @Select("SELECT COALESCE(SUM(paid_amount), 0) FROM t_order WHERE artisan_id = #{artisanId} AND status IN ('PRODUCING', 'STAGE_DELIVERING') AND deleted = 0")
    BigDecimal sumPendingIncomeByArtisanId(Long artisanId);

    @Select("SELECT COALESCE(SUM(total_amount), 0) FROM t_order WHERE artisan_id = #{artisanId} AND status = 'COMPLETED' AND deleted = 0")
    BigDecimal sumTotalIncomeByArtisanId(Long artisanId);

    // ========== 手作人端分页查询（避免全表加载到内存） ==========

    @Select("SELECT * FROM t_order WHERE artisan_id = #{artisanId} AND status IN ('PAID', 'PENDING_PAYMENT') AND deleted = 0 ORDER BY created_at DESC")
    Page<Order> findPendingOrdersByArtisanIdPage(Page<Order> page, Long artisanId);

    @Select("SELECT * FROM t_order WHERE artisan_id = #{artisanId} AND status = #{status} AND deleted = 0 ORDER BY created_at DESC")
    Page<Order> findByArtisanIdAndStatusPage(Page<Order> page, Long artisanId, OrderStatus status);

    @Select("SELECT * FROM t_order WHERE artisan_id = #{artisanId} AND deleted = 0 ORDER BY created_at DESC")
    Page<Order> findByArtisanIdPage(Page<Order> page, Long artisanId);

    @Select("SELECT * FROM t_order WHERE artisan_id = #{artisanId} AND status = 'COMPLETED' AND deleted = 0 ORDER BY completed_at DESC")
    Page<Order> findCompletedOrdersByArtisanIdPage(Page<Order> page, Long artisanId);

    @Select("SELECT COUNT(*) FROM t_order WHERE reference_images LIKE CONCAT('%', #{imageUrl}, '%') AND user_id = #{userId} AND deleted = 0")
    int existsByReferenceImageAndUserId(@org.apache.ibatis.annotations.Param("imageUrl") String imageUrl, @org.apache.ibatis.annotations.Param("userId") Long userId);
}

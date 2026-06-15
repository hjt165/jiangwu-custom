package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.OrderStage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface OrderStageRepository extends BaseMapper<OrderStage> {

    @Select("SELECT * FROM t_order_stage WHERE order_id = #{orderId} ORDER BY sort_order ASC")
    List<OrderStage> findByOrderId(Long orderId);

    @Select("SELECT * FROM t_order_stage WHERE id = #{id}")
    OrderStage findById(Long id);

    @Update("UPDATE t_order_stage SET status = #{status}, completed_at = #{completedAt}, updated_at = NOW() WHERE id = #{id}")
    int updateStatus(Long id, String status, LocalDateTime completedAt);

    @Update("UPDATE t_order_stage SET deliver_images = #{images}, deliver_note = #{note}, updated_at = NOW() WHERE id = #{id}")
    int updateDeliverInfo(Long id, String images, String note);
}

package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.Customization;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface CustomizationRepository extends BaseMapper<Customization> {

    @Select("SELECT * FROM t_customization WHERE order_id = #{orderId}")
    Customization findByOrderId(Long orderId);

    @Select("SELECT * FROM t_customization WHERE id = #{id}")
    Customization findById(Long id);

    @Select("<script>SELECT * FROM t_customization WHERE order_id IN " +
            "<foreach collection='orderIds' item='id' open='(' separator=',' close=')'>#{id}</foreach></script>")
    List<Customization> findByOrderIds(@org.apache.ibatis.annotations.Param("orderIds") List<Long> orderIds);
}

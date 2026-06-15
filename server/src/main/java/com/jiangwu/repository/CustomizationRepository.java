package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.Customization;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface CustomizationRepository extends BaseMapper<Customization> {

    @Select("SELECT * FROM t_customization WHERE order_id = #{orderId}")
    Customization findByOrderId(Long orderId);

    @Select("SELECT * FROM t_customization WHERE id = #{id}")
    Customization findById(Long id);
}

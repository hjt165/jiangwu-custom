package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.Material;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface MaterialRepository extends BaseMapper<Material> {

    @Select("SELECT * FROM t_material WHERE category = #{category} ORDER BY sort_order ASC")
    List<Material> findByCategory(String category);

    @Select("SELECT * FROM t_material ORDER BY category, sort_order ASC")
    List<Material> findAll();
}

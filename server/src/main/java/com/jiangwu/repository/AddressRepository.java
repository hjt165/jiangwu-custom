package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.Address;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface AddressRepository extends BaseMapper<Address> {

    @Select("SELECT * FROM t_address WHERE user_id = #{userId} ORDER BY is_default DESC, created_at DESC")
    List<Address> findByUserId(Long userId);

    @Select("SELECT * FROM t_address WHERE id = #{id}")
    Address findById(Long id);

    @Update("UPDATE t_address SET is_default = 0 WHERE user_id = #{userId} AND is_default = 1")
    int clearDefault(Long userId);
}

package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.User;
import com.jiangwu.enums.UserRole;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;

@Mapper
public interface UserRepository extends BaseMapper<User> {

    @Select("SELECT * FROM t_user WHERE phone = #{phone} AND deleted = 0")
    User findByPhone(String phone);

    @Select("SELECT * FROM t_user WHERE id = #{id} AND deleted = 0")
    User findById(Long id);

    @Update("UPDATE t_user SET last_login_at = #{loginTime}, updated_at = #{loginTime} WHERE id = #{id}")
    int updateLoginTime(Long id, LocalDateTime loginTime);

    @Update("UPDATE t_user SET role = #{role}, updated_at = NOW() WHERE id = #{id}")
    int updateRole(Long id, UserRole role);

    @Update("UPDATE t_user SET status = #{status}, updated_at = NOW() WHERE id = #{id}")
    int updateStatus(Long id, Integer status);
}

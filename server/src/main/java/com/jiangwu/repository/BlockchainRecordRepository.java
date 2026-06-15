package com.jiangwu.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangwu.entity.BlockchainRecord;
import com.jiangwu.enums.BlockchainType;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface BlockchainRecordRepository extends BaseMapper<BlockchainRecord> {

    @Select("SELECT * FROM t_blockchain_record WHERE id = #{id}")
    BlockchainRecord findById(Long id);

    @Select("SELECT * FROM t_blockchain_record WHERE order_id = #{orderId} ORDER BY timestamp ASC")
    List<BlockchainRecord> findByOrderId(Long orderId);

    @Select("SELECT * FROM t_blockchain_record WHERE order_id = #{orderId} AND type = #{type}")
    BlockchainRecord findByOrderIdAndType(Long orderId, BlockchainType type);
}

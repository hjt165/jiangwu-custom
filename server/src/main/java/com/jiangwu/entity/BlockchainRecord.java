package com.jiangwu.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import com.jiangwu.enums.BlockchainType;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 存证记录实体
 */
@Data
@TableName(value = "t_blockchain_record", autoResultMap = true)
public class BlockchainRecord {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long orderId;

    private BlockchainType type;

    private String transactionId;

    private String blockHash;

    private String dataHash;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> evidenceData;

    private String certificateUrl;

    private LocalDateTime timestamp;

    private Boolean isVerified;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}

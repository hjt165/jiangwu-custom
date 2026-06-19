-- ============================================
-- 匠物定制 - 数据库建表脚本
-- MySQL 8.x
-- ============================================

CREATE DATABASE IF NOT EXISTS `jiangwu_custom` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `jiangwu_custom`;

-- -------------------------------------------
-- 1. 用户表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE `t_user` (
    `id`           BIGINT       NOT NULL COMMENT '用户ID（雪花算法）',
    `phone`        VARCHAR(20)  NOT NULL COMMENT '手机号',
    `password`     VARCHAR(128) DEFAULT NULL COMMENT '密码（加密后）',
    `nickname`     VARCHAR(50)  DEFAULT NULL COMMENT '昵称',
    `avatar`       VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
    `role`         TINYINT      NOT NULL DEFAULT 0 COMMENT '角色：0-普通用户 1-手作人 2-管理员',
    `credit_score` INT          NOT NULL DEFAULT 100 COMMENT '信用分',
    `status`       TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-正常',
    `last_login_at` DATETIME    DEFAULT NULL COMMENT '最后登录时间',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`      TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-未删除 1-已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- -------------------------------------------
-- 2. 手作人表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_artisan`;
CREATE TABLE `t_artisan` (
    `id`              BIGINT       NOT NULL COMMENT '手作人ID',
    `user_id`         BIGINT       NOT NULL COMMENT '关联用户ID',
    `name`            VARCHAR(100) NOT NULL COMMENT '手作人名称',
    `avatar`          VARCHAR(500) DEFAULT NULL COMMENT '头像',
    `bio`             TEXT         DEFAULT NULL COMMENT '个人简介',
    `specialty`       VARCHAR(200) DEFAULT NULL COMMENT '擅长工艺',
    `years_of_exp`    INT          DEFAULT 0 COMMENT '从业年限',
    `location`        VARCHAR(200) DEFAULT NULL COMMENT '所在地',
    `rating`          DECIMAL(3,2) DEFAULT 0.00 COMMENT '综合评分',
    `order_count`     INT          DEFAULT 0 COMMENT '完成订单数',
    `fan_count`       INT          DEFAULT 0 COMMENT '粉丝数',
    `certifications`  TEXT         DEFAULT NULL COMMENT '资质认证（JSON数组）',
    `status`          TINYINT      NOT NULL DEFAULT 0 COMMENT '状态：0-待审核 1-已认证 2-已拒绝 3-已封禁',
    `applied_at`      DATETIME     DEFAULT NULL COMMENT '申请时间',
    `approved_at`     DATETIME     DEFAULT NULL COMMENT '审核通过时间',
    `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`         TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    KEY `idx_specialty` (`specialty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='手作人表';

-- -------------------------------------------
-- 3. 作品表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_product`;
CREATE TABLE `t_product` (
    `id`              BIGINT        NOT NULL COMMENT '作品ID',
    `artisan_id`      BIGINT        NOT NULL COMMENT '手作人ID',
    `title`           VARCHAR(200)  NOT NULL COMMENT '作品标题',
    `description`     TEXT          DEFAULT NULL COMMENT '作品描述',
    `category`        VARCHAR(50)   NOT NULL COMMENT '分类：jewelry/leather/ceramic/woodwork/painting/other',
    `cover_image`     VARCHAR(500)  DEFAULT NULL COMMENT '封面图',
    `price`           DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '价格',
    `original_price`  DECIMAL(10,2) DEFAULT NULL COMMENT '原价',
    `craft_params`    TEXT          DEFAULT NULL COMMENT '工艺参数（JSON）',
    `materials`       TEXT          DEFAULT NULL COMMENT '材质列表（JSON数组）',
    `tags`            TEXT          DEFAULT NULL COMMENT '标签（JSON数组）',
    `view_count`      INT           DEFAULT 0 COMMENT '浏览量',
    `like_count`      INT           DEFAULT 0 COMMENT '收藏量',
    `order_count`     INT           DEFAULT 0 COMMENT '下单量',
    `rating`          DECIMAL(3,2)  DEFAULT 0.00 COMMENT '评分',
    `is_featured`     TINYINT       DEFAULT 0 COMMENT '是否推荐',
    `is_available`    TINYINT       DEFAULT 1 COMMENT '是否可售',
    `created_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`         TINYINT       NOT NULL DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_artisan_id` (`artisan_id`),
    KEY `idx_category` (`category`),
    KEY `idx_is_featured` (`is_featured`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作品表';

-- -------------------------------------------
-- 4. 作品图片表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_product_image`;
CREATE TABLE `t_product_image` (
    `id`              BIGINT       NOT NULL COMMENT '图片ID',
    `product_id`      BIGINT       NOT NULL COMMENT '作品ID',
    `image_url`       VARCHAR(500) NOT NULL COMMENT '图片URL',
    `description`     VARCHAR(500) DEFAULT NULL COMMENT '图片描述',
    `sort_order`      INT          DEFAULT 0 COMMENT '排序',
    `review_status`   TINYINT      NOT NULL DEFAULT 0 COMMENT '审核状态：0-待审核 1-已通过 2-已拒绝',
    `review_remark`   VARCHAR(500) DEFAULT NULL COMMENT '审核备注',
    `reviewer_id`     BIGINT       DEFAULT NULL COMMENT '审核人ID',
    `reviewed_at`     DATETIME     DEFAULT NULL COMMENT '审核时间',
    `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_product_id` (`product_id`),
    KEY `idx_review_status` (`review_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作品图片表';

-- -------------------------------------------
-- 5. 订单表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_order`;
CREATE TABLE `t_order` (
    `id`              BIGINT        NOT NULL COMMENT '订单ID',
    `order_no`        VARCHAR(32)   NOT NULL COMMENT '订单编号',
    `user_id`         BIGINT        NOT NULL COMMENT '用户ID',
    `artisan_id`      BIGINT        DEFAULT NULL COMMENT '手作人ID',
    `product_id`      BIGINT        DEFAULT NULL COMMENT '作品ID',
    `status`          VARCHAR(30)   NOT NULL DEFAULT 'pending_payment' COMMENT '订单状态',
    `total_amount`    DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '订单总额',
    `paid_amount`     DECIMAL(10,2) DEFAULT 0.00 COMMENT '已付金额',
    `deposit_amount`  DECIMAL(10,2) DEFAULT 0.00 COMMENT '押金金额',
    `current_stage`   INT           DEFAULT 0 COMMENT '当前阶段索引',
    `remark`          VARCHAR(500)  DEFAULT NULL COMMENT '订单备注',
    `paid_at`         DATETIME      DEFAULT NULL COMMENT '支付时间',
    `completed_at`    DATETIME      DEFAULT NULL COMMENT '完成时间',
    `cancelled_at`    DATETIME      DEFAULT NULL COMMENT '取消时间',
    `cancel_reason`   VARCHAR(500)  DEFAULT NULL COMMENT '取消原因',
    `created_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`         TINYINT       NOT NULL DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_artisan_id` (`artisan_id`),
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- -------------------------------------------
-- 6. 订单阶段表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_order_stage`;
CREATE TABLE `t_order_stage` (
    `id`             BIGINT       NOT NULL COMMENT '阶段ID',
    `order_id`       BIGINT       NOT NULL COMMENT '订单ID',
    `name`           VARCHAR(100) NOT NULL COMMENT '阶段名称',
    `description`    TEXT         DEFAULT NULL COMMENT '阶段描述',
    `status`         VARCHAR(30)  NOT NULL DEFAULT 'pending' COMMENT '阶段状态',
    `sort_order`     INT          DEFAULT 0 COMMENT '排序',
    `due_date`       DATETIME     DEFAULT NULL COMMENT '截止日期',
    `completed_at`   DATETIME     DEFAULT NULL COMMENT '完成时间',
    `deliver_images` TEXT         DEFAULT NULL COMMENT '交付图片（JSON数组）',
    `deliver_note`   TEXT         DEFAULT NULL COMMENT '交付说明',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单阶段表';

-- -------------------------------------------
-- 7. 定制参数表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_customization`;
CREATE TABLE `t_customization` (
    `id`                BIGINT       NOT NULL COMMENT '定制ID',
    `order_id`          BIGINT       NOT NULL COMMENT '订单ID',
    `product_id`        BIGINT       DEFAULT NULL COMMENT '作品ID（参考作品）',
    `material`          VARCHAR(100) DEFAULT NULL COMMENT '材质',
    `size`              VARCHAR(100) DEFAULT NULL COMMENT '尺寸',
    `color`             VARCHAR(50)  DEFAULT NULL COMMENT '颜色',
    `engraving`         VARCHAR(200) DEFAULT NULL COMMENT '刻字内容',
    `reference_images`  TEXT         DEFAULT NULL COMMENT '参考图片（JSON数组）',
    `special_requests`  TEXT         DEFAULT NULL COMMENT '特殊要求',
    `ai_suggestion`     TEXT         DEFAULT NULL COMMENT 'AI分析建议',
    `additional_params` TEXT         DEFAULT NULL COMMENT '扩展参数（JSON）',
    `created_at`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='定制参数表';

-- -------------------------------------------
-- 8. 评价表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_review`;
CREATE TABLE `t_review` (
    `id`            BIGINT   NOT NULL COMMENT '评价ID',
    `order_id`      BIGINT   NOT NULL COMMENT '订单ID',
    `user_id`       BIGINT   NOT NULL COMMENT '用户ID',
    `artisan_id`    BIGINT   DEFAULT NULL COMMENT '手作人ID',
    `rating`        TINYINT  NOT NULL COMMENT '评分（1-5）',
    `content`       TEXT     DEFAULT NULL COMMENT '评价内容',
    `images`        TEXT     DEFAULT NULL COMMENT '评价图片（JSON数组）',
    `tags`          TEXT     DEFAULT NULL COMMENT '评价标签（JSON数组）',
    `is_anonymous`  TINYINT  DEFAULT 0 COMMENT '是否匿名',
    `reply`         TEXT     DEFAULT NULL COMMENT '手作人回复',
    `reply_at`      DATETIME DEFAULT NULL COMMENT '回复时间',
    `review_status` TINYINT  NOT NULL DEFAULT 0 COMMENT '审核状态：0-待审核 1-已通过 2-已拒绝',
    `review_remark` VARCHAR(500) DEFAULT NULL COMMENT '审核备注',
    `reviewer_id`   BIGINT   DEFAULT NULL COMMENT '审核人ID',
    `reviewed_at`   DATETIME DEFAULT NULL COMMENT '审核时间',
    `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`       TINYINT  NOT NULL DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_id` (`order_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_artisan_id` (`artisan_id`),
    KEY `idx_review_status` (`review_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评价表';

-- -------------------------------------------
-- 9. 存证记录表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_blockchain_record`;
CREATE TABLE `t_blockchain_record` (
    `id`              BIGINT       NOT NULL COMMENT '记录ID',
    `order_id`        BIGINT       NOT NULL COMMENT '订单ID',
    `type`            VARCHAR(50)  NOT NULL COMMENT '存证类型',
    `transaction_id`  VARCHAR(128) DEFAULT NULL COMMENT '交易ID',
    `block_hash`      VARCHAR(128) NOT NULL COMMENT '区块哈希',
    `data_hash`       VARCHAR(128) NOT NULL COMMENT '数据哈希',
    `evidence_data`   TEXT         DEFAULT NULL COMMENT '存证数据（JSON）',
    `certificate_url` VARCHAR(500) DEFAULT NULL COMMENT '证书URL',
    `timestamp`       DATETIME     NOT NULL COMMENT '存证时间',
    `is_verified`     TINYINT      DEFAULT 0 COMMENT '是否已验证',
    `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='存证记录表';

-- -------------------------------------------
-- 10. 材质表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_material`;
CREATE TABLE `t_material` (
    `id`          BIGINT       NOT NULL COMMENT '材质ID',
    `category`    VARCHAR(50)  NOT NULL COMMENT '所属分类',
    `name`        VARCHAR(100) NOT NULL COMMENT '材质名称',
    `description` VARCHAR(500) DEFAULT NULL COMMENT '描述',
    `options`     TEXT         DEFAULT NULL COMMENT '可选项（JSON）',
    `sort_order`  INT          DEFAULT 0 COMMENT '排序',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='材质表';

-- -------------------------------------------
-- 11. 用户收藏表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_user_favorite`;
CREATE TABLE `t_user_favorite` (
    `id`         BIGINT   NOT NULL COMMENT '收藏ID',
    `user_id`    BIGINT   NOT NULL COMMENT '用户ID',
    `product_id` BIGINT   NOT NULL COMMENT '作品ID',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_product` (`user_id`, `product_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户收藏表';

-- -------------------------------------------
-- 12. 浏览历史表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_browse_history`;
CREATE TABLE `t_browse_history` (
    `id`         BIGINT   NOT NULL COMMENT '记录ID',
    `user_id`    BIGINT   NOT NULL COMMENT '用户ID',
    `product_id` BIGINT   NOT NULL COMMENT '作品ID',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '浏览时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_product_id` (`product_id`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='浏览历史表';

-- -------------------------------------------
-- 13. 用户关注表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_user_follow`;
CREATE TABLE `t_user_follow` (
    `id`          BIGINT   NOT NULL COMMENT '关注ID',
    `user_id`     BIGINT   NOT NULL COMMENT '用户ID',
    `artisan_id`  BIGINT   NOT NULL COMMENT '手作人ID',
    `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_artisan` (`user_id`, `artisan_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_artisan_id` (`artisan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户关注表';

-- -------------------------------------------
-- 14. 会话表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_conversation`;
CREATE TABLE `t_conversation` (
    `id`              BIGINT       NOT NULL COMMENT '会话ID',
    `user_id`         BIGINT       NOT NULL COMMENT '用户ID',
    `artisan_id`      BIGINT       NOT NULL COMMENT '手作人ID',
    `order_id`        BIGINT       DEFAULT NULL COMMENT '关联订单ID',
    `last_message`    VARCHAR(500) DEFAULT NULL COMMENT '最后一条消息',
    `last_message_at` DATETIME     DEFAULT NULL COMMENT '最后消息时间',
    `user_unread`     INT          NOT NULL DEFAULT 0 COMMENT '用户未读数',
    `artisan_unread`  INT          NOT NULL DEFAULT 0 COMMENT '手作人未读数',
    `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_artisan` (`user_id`, `artisan_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_artisan_id` (`artisan_id`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_last_message_at` (`last_message_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会话表';

-- -------------------------------------------
-- 15. 消息表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_message`;
CREATE TABLE `t_message` (
    `id`              BIGINT       NOT NULL COMMENT '消息ID',
    `conversation_id` BIGINT       NOT NULL COMMENT '会话ID',
    `sender_id`       BIGINT       NOT NULL COMMENT '发送者ID',
    `content`         TEXT         NOT NULL COMMENT '消息内容',
    `message_type`    VARCHAR(20)  NOT NULL DEFAULT 'text' COMMENT '消息类型：text/image/file',
    `status`          TINYINT      NOT NULL DEFAULT 0 COMMENT '状态：0-发送中 1-已发送 2-已读',
    `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
    PRIMARY KEY (`id`),
    KEY `idx_conversation_id` (`conversation_id`),
    KEY `idx_sender_id` (`sender_id`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息表';

-- -------------------------------------------
-- 16. 收货地址表
-- -------------------------------------------
DROP TABLE IF EXISTS `t_address`;
CREATE TABLE `t_address` (
    `id`         BIGINT       NOT NULL COMMENT '地址ID',
    `user_id`    BIGINT       NOT NULL COMMENT '用户ID',
    `name`       VARCHAR(50)  NOT NULL COMMENT '收货人姓名',
    `phone`      VARCHAR(20)  NOT NULL COMMENT '手机号',
    `province`   VARCHAR(50)  NOT NULL COMMENT '省份',
    `city`       VARCHAR(50)  NOT NULL COMMENT '城市',
    `district`   VARCHAR(50)  NOT NULL COMMENT '区县',
    `detail`     VARCHAR(200) NOT NULL COMMENT '详细地址',
    `is_default` TINYINT      NOT NULL DEFAULT 0 COMMENT '是否默认：0-否 1-是',
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收货地址表';

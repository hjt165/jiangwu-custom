-- 匠物定制 数据库索引优化脚本
-- 执行前请备份数据库
-- MySQL 8.0+ ALTER TABLE ADD INDEX 为幂等操作（索引已存在则静默忽略）

-- 作品表索引
ALTER TABLE `t_product` ADD INDEX `idx_product_artisan_id` (`artisan_id`);
ALTER TABLE `t_product` ADD INDEX `idx_product_category` (`category`);
ALTER TABLE `t_product` ADD INDEX `idx_product_featured_available` (`is_featured`, `is_available`);
ALTER TABLE `t_product` ADD INDEX `idx_product_created_at` (`created_at`);

-- 订单表索引
ALTER TABLE `t_order` ADD INDEX `idx_order_user_id` (`user_id`);
ALTER TABLE `t_order` ADD INDEX `idx_order_artisan_id` (`artisan_id`);
ALTER TABLE `t_order` ADD INDEX `idx_order_status` (`status`);
ALTER TABLE `t_order` ADD UNIQUE INDEX `uk_order_order_no` (`order_no`);
ALTER TABLE `t_order` ADD INDEX `idx_order_created_at` (`created_at`);

-- 订单阶段表索引
ALTER TABLE `t_order_stage` ADD INDEX `idx_order_stage_order_id` (`order_id`);

-- 作品图片表索引
ALTER TABLE `t_product_image` ADD INDEX `idx_product_image_product_id` (`product_id`);

-- 评价表索引
ALTER TABLE `t_review` ADD INDEX `idx_review_order_id` (`order_id`);
ALTER TABLE `t_review` ADD INDEX `idx_review_artisan_id` (`artisan_id`);
ALTER TABLE `t_review` ADD INDEX `idx_review_user_id` (`user_id`);

-- 浏览历史表索引
ALTER TABLE `t_browse_history` ADD INDEX `idx_browse_history_user_id` (`user_id`);
ALTER TABLE `t_browse_history` ADD INDEX `idx_browse_history_user_product` (`user_id`, `product_id`);

-- 收藏表索引
ALTER TABLE `t_user_favorite` ADD INDEX `idx_user_favorite_user_id` (`user_id`);
ALTER TABLE `t_user_favorite` ADD INDEX `idx_user_favorite_user_product` (`user_id`, `product_id`);

-- 关注表索引
ALTER TABLE `t_user_follow` ADD INDEX `idx_user_follow_user_id` (`user_id`);
ALTER TABLE `t_user_follow` ADD INDEX `idx_user_follow_artisan_id` (`artisan_id`);

-- 会话表索引
ALTER TABLE `t_conversation` ADD INDEX `idx_conversation_user_id` (`user_id`);
ALTER TABLE `t_conversation` ADD INDEX `idx_conversation_artisan_id` (`artisan_id`);

-- 消息表索引
ALTER TABLE `t_message` ADD INDEX `idx_message_conversation_id` (`conversation_id`);
ALTER TABLE `t_message` ADD INDEX `idx_message_created_at` (`created_at`);

-- 区块链记录表索引
ALTER TABLE `t_blockchain_record` ADD INDEX `idx_blockchain_record_order_id` (`order_id`);

-- 定制参数表索引
ALTER TABLE `t_customization` ADD INDEX `idx_customization_order_id` (`order_id`);

-- 复合索引: 手作人订单查询 (artisan_id + status)
ALTER TABLE `t_order` ADD INDEX `idx_order_artisan_status` (`artisan_id`, `status`);

-- 复合索引: 地址默认查询 (user_id + is_default)
ALTER TABLE `t_address` ADD INDEX `idx_address_user_default` (`user_id`, `is_default`);

-- 作品标题索引
ALTER TABLE `t_product` ADD INDEX `idx_product_title` (`title`);
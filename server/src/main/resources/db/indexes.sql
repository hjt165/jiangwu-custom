-- 匠物定制 数据库索引优化脚本
-- 执行前请备份数据库

-- 作品表索引
CREATE INDEX IF NOT EXISTS idx_product_artisan_id ON t_product(artisan_id);
CREATE INDEX IF NOT EXISTS idx_product_category ON t_product(category);
CREATE INDEX IF NOT EXISTS idx_product_featured_available ON t_product(is_featured, is_available);
CREATE INDEX IF NOT EXISTS idx_product_created_at ON t_product(created_at);

-- 订单表索引
CREATE INDEX IF NOT EXISTS idx_order_user_id ON t_order(user_id);
CREATE INDEX IF NOT EXISTS idx_order_artisan_id ON t_order(artisan_id);
CREATE INDEX IF NOT EXISTS idx_order_status ON t_order(status);
CREATE UNIQUE INDEX IF NOT EXISTS uk_order_order_no ON t_order(order_no);
CREATE INDEX IF NOT EXISTS idx_order_created_at ON t_order(created_at);

-- 订单阶段表索引
CREATE INDEX IF NOT EXISTS idx_order_stage_order_id ON t_order_stage(order_id);

-- 作品图片表索引
CREATE INDEX IF NOT EXISTS idx_product_image_product_id ON t_product_image(product_id);

-- 评价表索引
CREATE INDEX IF NOT EXISTS idx_review_order_id ON t_review(order_id);
CREATE INDEX IF NOT EXISTS idx_review_artisan_id ON t_review(artisan_id);
CREATE INDEX IF NOT EXISTS idx_review_user_id ON t_review(user_id);

-- 浏览历史表索引
CREATE INDEX IF NOT EXISTS idx_browse_history_user_id ON t_browse_history(user_id);
CREATE INDEX IF NOT EXISTS idx_browse_history_user_product ON t_browse_history(user_id, product_id);

-- 收藏表索引
CREATE INDEX IF NOT EXISTS idx_user_favorite_user_id ON t_user_favorite(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorite_user_product ON t_user_favorite(user_id, product_id);

-- 关注表索引
CREATE INDEX IF NOT EXISTS idx_user_follow_user_id ON t_user_follow(user_id);
CREATE INDEX IF NOT EXISTS idx_user_follow_artisan_id ON t_user_follow(artisan_id);

-- 会话表索引
CREATE INDEX IF NOT EXISTS idx_conversation_user_id ON t_conversation(user_id);
CREATE INDEX IF NOT EXISTS idx_conversation_artisan_id ON t_conversation(artisan_id);

-- 消息表索引
CREATE INDEX IF NOT EXISTS idx_message_conversation_id ON t_message(conversation_id);
CREATE INDEX IF NOT EXISTS idx_message_created_at ON t_message(created_at);

-- 区块链记录表索引
CREATE INDEX IF NOT EXISTS idx_blockchain_record_order_id ON t_blockchain_record(order_id);

-- 定制参数表索引
CREATE INDEX IF NOT EXISTS idx_customization_order_id ON t_customization(order_id);

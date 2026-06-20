-- ============================================
-- 匠物定制 - 初始化数据
-- ============================================

USE `jiangwu_custom`;

-- 管理员账号（密码: admin123，BCrypt 加密）
INSERT INTO `t_user` (`id`, `phone`, `password`, `nickname`, `role`, `status`)
VALUES (1, '13800000000', '$2b$12$tmVqXo61qdobp6cgwrfQCOwwBO/WuwRSQNGIpDqWyUEeRCwzl6MsW', '管理员', 2, 1);

-- 测试用户账号（密码: user123）
INSERT INTO `t_user` (`id`, `phone`, `password`, `nickname`, `role`, `status`)
VALUES (2, '13800000001', '$2b$12$GzUSG8qhbwygUC9NmaTfC.n993Be9xoAsCzPI7wzdFbpsT8l6IvgW', '测试用户', 0, 1);

-- 测试手作人账号（密码: artisan123）
INSERT INTO `t_user` (`id`, `phone`, `password`, `nickname`, `role`, `status`)
VALUES (3, '13800000002', '$2b$12$F76sCxCBRWZCHwSZNQe4UORmLlMyek3OTckxLkVUY8wYWtgOFsSpu', '手作达人', 1, 1);

-- 测试手作人资料
INSERT INTO `t_artisan` (`id`, `user_id`, `name`, `bio`, `specialty`, `years_of_exp`, `location`, `rating`, `order_count`, `status`)
VALUES (1, 3, '匠心手作', '十年手工皮具制作经验，专注原创设计', '皮具,首饰', 10, '上海', 4.80, 156, 1);

-- 材质数据
INSERT INTO `t_material` (`id`, `category`, `name`, `description`, `options`, `sort_order`) VALUES
(1, 'jewelry', '925银', '国际标准银', NULL, 1),
(2, 'jewelry', '18K金', '黄金合金', NULL, 2),
(3, 'jewelry', '铂金PT950', '高纯度铂金', NULL, 3),
(4, 'leather', '植鞣牛皮', '天然鞣制牛皮', '{"颜色":["原色","棕色","黑色"]}', 1),
(5, 'leather', '铬鞣羊皮', '柔软羊皮', '{"颜色":["黑色","白色","红色"]}', 2),
(6, 'ceramic', '高白瓷', '高温烧制白瓷', NULL, 1),
(7, 'ceramic', '紫砂', '宜兴紫砂', NULL, 2),
(8, 'woodwork', '小叶紫檀', '珍贵红木', NULL, 1),
(9, 'woodwork', '黑胡桃木', '进口硬木', NULL, 2),
(10, 'woodwork', '黄杨木', '传统雕刻用材', NULL, 3);

-- 意见反馈测试数据
INSERT INTO `t_feedback` (`id`, `user_id`, `content`, `contact`, `status`, `reply`) VALUES
(1, 2, '希望能增加更多手作人入驻', NULL, 0, NULL),
(2, 2, '下单流程有点复杂，建议简化', '13800000001', 1, '感谢反馈，我们会优化下单流程'),
(3, 3, '作品展示页面加载较慢，建议优化图片加载', NULL, 2, NULL);

-- 作品测试数据
INSERT INTO `t_product` (`id`, `artisan_id`, `title`, `description`, `category`, `cover_image`, `price`, `original_price`, `materials`, `tags`, `view_count`, `like_count`, `order_count`, `rating`, `is_featured`, `is_available`, `review_status`) VALUES
(1, 1, '翡翠平安扣吊坠', '天然A货翡翠，冰种飘花，寓意平安吉祥', 'jewelry', 'https://picsum.photos/seed/jade1/400/400', 1299.00, 1599.00, '["翡翠","925银"]', '["精品","限量","送礼"]', 320, 85, 23, 4.80, 1, 1, 1),
(2, 1, '手工植鞣牛皮钱包', '意大利植鞣牛皮，手工缝制，越用越有味道', 'leather', 'https://picsum.photos/seed/leather1/400/400', 399.00, 499.00, '["植鞣牛皮"]', '["手工","真皮","简约"]', 256, 62, 18, 4.70, 1, 1, 1),
(3, 1, '宜兴紫砂壶·石瓢', '原矿紫砂泥，全手工制作，容量约200ml', 'ceramic', 'https://picsum.photos/seed/zisha1/400/400', 680.00, NULL, '["紫砂"]', '["茶道","手工","收藏"]', 189, 45, 12, 4.90, 1, 1, 1),
(4, 1, '小叶紫檀手串', '印度小叶紫檀老料，15mm×15颗，佛珠款', 'woodwork', 'https://picsum.photos/seed/wood1/400/400', 258.00, 328.00, '["小叶紫檀"]', '["佛珠","文玩","男士"]', 410, 98, 35, 4.60, 1, 1, 1),
(5, 1, '青花瓷马克杯', '手绘青花图案，高温烧制，安全无铅', 'ceramic', 'https://picsum.photos/seed/cup1/400/400', 168.00, NULL, '["高白瓷"]', '["日用","手绘","中国风"]', 520, 120, 42, 4.50, 0, 1, 1),
(6, 1, '银杏叶胸针', '925银手工锻造，天然珐琅彩绘', 'jewelry', 'https://picsum.photos/seed/brooch1/400/400', 458.00, 520.00, '["925银","珐琅"]', '["胸针","自然","精致"]', 178, 52, 8, 4.85, 1, 1, 1),
(7, 1, '牛皮手工表带', '头层牛皮，手工植鞣，适配主流手表', 'leather', 'https://picsum.photos/seed/strap1/400/400', 128.00, NULL, '["头层牛皮"]', '["表带","配件","手工"]', 345, 78, 28, 4.40, 0, 1, 1),
(8, 1, '黄杨木雕·弥勒佛', '乐清黄杨木雕，精细镂空，高约12cm', 'woodwork', 'https://picsum.photos/seed/wood2/400/400', 880.00, 999.00, '["黄杨木"]', '["摆件","佛像","收藏"]', 156, 42, 5, 4.95, 1, 1, 1);

-- 评价测试数据
INSERT INTO `t_review` (`id`, `order_id`, `user_id`, `artisan_id`, `rating`, `content`, `images`, `created_at`) VALUES
(1, NULL, 2, 1, 5, '翡翠品质非常好，做工精细，物流也快！', '["https://picsum.photos/seed/r1/200/200"]', '2026-06-01 10:30:00'),
(2, NULL, 2, 1, 4, '钱包手感不错，就是颜色比图片稍深', NULL, '2026-06-05 14:20:00'),
(3, NULL, 2, 1, 5, '紫砂壶做工很精细，泡茶口感很好', '["https://picsum.photos/seed/r3/200/200","https://picsum.photos/seed/r3b/200/200"]', '2026-06-10 09:15:00'),
(4, NULL, 2, 1, 4, '手串质量不错，盘了几天已经有光泽了', NULL, '2026-06-12 16:45:00'),
(5, NULL, 2, 1, 5, '杯子很漂亮，手绘图案很有艺术感', NULL, '2026-06-15 11:00:00');

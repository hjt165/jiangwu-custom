-- ============================================
-- 匠物定制 - 初始化数据
-- ============================================

USE `jiangwu_custom`;

-- 管理员账号（密码: admin123，SHA-256 加密）
INSERT INTO `t_user` (`id`, `phone`, `password`, `nickname`, `role`, `status`)
VALUES (1, '13800000000', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', '管理员', 2, 1);

-- 测试用户账号（密码: user123）
INSERT INTO `t_user` (`id`, `phone`, `password`, `nickname`, `role`, `status`)
VALUES (2, '13800000001', '0457b427d6f35a33e330d80b48e1004f3e0308b2e0e4a6b1c2d3e4f5a6b7c8d9', '测试用户', 0, 1);

-- 测试手作人账号（密码: artisan123）
INSERT INTO `t_user` (`id`, `phone`, `password`, `nickname`, `role`, `status`)
VALUES (3, '13800000002', 'f6a8d7e9c0b1a2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7', '手作达人', 1, 1);

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

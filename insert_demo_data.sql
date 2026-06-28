USE jiangwu_custom;

-- Step 1: Users (14-18)
INSERT IGNORE INTO t_user (id, phone, password, nickname, role, credit_score, status, created_at, updated_at, deleted) VALUES
(14, '13920000001', '$2b$12$tmVqXo61qdobp6cgwrfQCOwwBO/WuwRSQNGIpDqWyUEeRCwzl6MsW', 'Lin', 0, 100, 1, NOW(), NOW(), 0),
(15, '13920000002', '$2b$12$tmVqXo61qdobp6cgwrfQCOwwBO/WuwRSQNGIpDqWyUEeRCwzl6MsW', 'Liu', 0, 100, 1, NOW(), NOW(), 0),
(16, '13920000003', '$2b$12$tmVqXo61qdobp6cgwrfQCOwwBO/WuwRSQNGIpDqWyUEeRCwzl6MsW', 'He', 0, 100, 1, NOW(), NOW(), 0),
(17, '13920000004', '$2b$12$tmVqXo61qdobp6cgwrfQCOwwBO/WuwRSQNGIpDqWyUEeRCwzl6MsW', 'Luo', 0, 100, 1, NOW(), NOW(), 0),
(18, '13920000005', '$2b$12$tmVqXo61qdobp6cgwrfQCOwwBO/WuwRSQNGIpDqWyUEeRCwzl6MsW', 'Xie', 0, 100, 1, NOW(), NOW(), 0);

-- Step 2: Addresses
INSERT IGNORE INTO t_address (id, user_id, name, phone, province, city, district, detail, is_default, created_at, updated_at) VALUES
(1, 4, 'Zhang', '13910000001', 'ZJ', 'HZ', 'XH', 'WenSanRoad', 1, NOW(), NOW()),
(2, 5, 'Li', '13910000002', 'GD', 'GZ', 'TH', 'TianHeRoad', 1, NOW(), NOW()),
(3, 6, 'Wang', '13910000003', 'BJ', 'BJ', 'CY', 'JianGuoMen', 1, NOW(), NOW()),
(4, 7, 'Zhao', '13910000004', 'SC', 'CD', 'JJ', 'ChunXiLu', 1, NOW(), NOW()),
(5, 8, 'Sun', '13910000005', 'HB', 'WH', 'WC', 'ZhongNanLu', 1, NOW(), NOW()),
(6, 9, 'Zhou', '13910000006', 'FJ', 'XM', 'SM', 'ZhongShanLu', 1, NOW(), NOW()),
(7, 10, 'Wu', '13910000007', 'SD', 'QD', 'SN', 'XiangGangZhongLu', 1, NOW(), NOW()),
(8, 11, 'Zheng', '13910000008', 'SA', 'XA', 'BL', 'NanDaJie', 1, NOW(), NOW()),
(9, 12, 'Chen', '13910000009', 'CQ', 'CQ', 'YZ', 'JieFangBei', 1, NOW(), NOW()),
(10, 13, 'Lin', '13910000010', 'YN', 'KM', 'WH', 'DongFengXiLu', 1, NOW(), NOW());

-- Step 3: Orders
INSERT IGNORE INTO t_order (id, order_no, user_id, artisan_id, product_id, status, total_amount, paid_amount, deposit_amount, current_stage, paid_at, completed_at, created_at, updated_at, deleted) VALUES
(1, 'ORD20260601001', 4, 1, 1, 'completed', 1299.00, 1299.00, 300.00, 4, '2026-06-01 10:00:00', '2026-06-03 16:00:00', '2026-06-01 09:55:00', '2026-06-03 16:00:00', 0),
(2, 'ORD20260602001', 5, 1, 2, 'completed', 399.00, 399.00, 100.00, 4, '2026-06-02 14:00:00', '2026-06-05 10:00:00', '2026-06-02 13:50:00', '2026-06-05 10:00:00', 0),
(3, 'ORD20260603001', 6, 1, 3, 'completed', 2580.00, 2580.00, 500.00, 4, '2026-06-03 09:00:00', '2026-06-06 14:00:00', '2026-06-03 08:45:00', '2026-06-06 14:00:00', 0),
(4, 'ORD20260604001', 7, 1, 4, 'completed', 880.00, 880.00, 200.00, 4, '2026-06-04 16:00:00', '2026-06-07 11:00:00', '2026-06-04 15:30:00', '2026-06-07 11:00:00', 0),
(5, 'ORD20260605001', 8, 1, 5, 'shipped', 1680.00, 1680.00, 400.00, 3, '2026-06-05 11:00:00', NULL, '2026-06-05 10:30:00', '2026-06-08 09:00:00', 0),
(6, 'ORD20260606001', 9, 1, 6, 'shipped', 780.00, 780.00, 200.00, 3, '2026-06-06 15:00:00', NULL, '2026-06-06 14:45:00', '2026-06-09 12:00:00', 0),
(7, 'ORD20260607001', 10, 1, 7, 'paid', 2100.00, 2100.00, 500.00, 1, '2026-06-07 09:00:00', NULL, '2026-06-07 08:30:00', '2026-06-07 09:00:00', 0),
(8, 'ORD20260608001', 11, 1, 8, 'paid', 1560.00, 1560.00, 400.00, 1, '2026-06-08 10:00:00', NULL, '2026-06-08 09:45:00', '2026-06-08 10:00:00', 0),
(9, 'ORD20260609001', 12, 1, 1, 'in_production', 1599.00, 1599.00, 400.00, 2, '2026-06-09 14:00:00', NULL, '2026-06-09 13:30:00', '2026-06-10 08:00:00', 0),
(10, 'ORD20260610001', 13, 1, 2, 'in_production', 499.00, 499.00, 100.00, 2, '2026-06-10 11:00:00', NULL, '2026-06-10 10:30:00', '2026-06-11 09:00:00', 0),
(11, 'ORD20260611001', 4, 1, 3, 'pending_delivery', 2990.00, 2990.00, 600.00, 3, '2026-06-11 09:00:00', NULL, '2026-06-11 08:00:00', '2026-06-12 14:00:00', 0),
(12, 'ORD20260612001', 5, 1, 4, 'pending_delivery', 1280.00, 1280.00, 300.00, 3, '2026-06-12 15:00:00', NULL, '2026-06-12 14:30:00', '2026-06-13 10:00:00', 0),
(13, 'ORD20260613001', 6, 1, 5, 'pending_payment', 4200.00, NULL, NULL, 0, NULL, NULL, '2026-06-13 09:00:00', '2026-06-13 09:00:00', 0),
(14, 'ORD20260614001', 7, 1, 6, 'pending_payment', 880.00, NULL, NULL, 0, NULL, NULL, '2026-06-14 10:00:00', '2026-06-14 10:00:00', 0),
(15, 'ORD20260615001', 8, 1, 7, 'cancelled', 3500.00, 3500.00, 700.00, 1, '2026-06-15 08:00:00', NULL, '2026-06-15 07:30:00', '2026-06-15 16:00:00', 0),
(16, 'ORD20260616001', 9, 1, 8, 'cancelled', 1680.00, 1680.00, 400.00, 0, NULL, NULL, '2026-06-16 13:45:00', '2026-06-16 20:00:00', 0);

-- Step 4: Order stages
INSERT IGNORE INTO t_order_stage (id, order_id, name, description, status, sort_order, due_date, completed_at, created_at, updated_at) VALUES
(1, 1, 'Design', 'Confirm design', 'completed', 1, '2026-06-02 10:00:00', '2026-06-01 14:00:00', NOW(), NOW()),
(2, 1, 'Making', 'Crafting', 'completed', 2, '2026-06-03 10:00:00', '2026-06-03 09:00:00', NOW(), NOW()),
(3, 1, 'QC', 'Quality check', 'completed', 3, '2026-06-03 16:00:00', '2026-06-03 15:00:00', NOW(), NOW()),
(4, 9, 'Design', 'Confirm vase shape', 'completed', 1, '2026-06-10 10:00:00', '2026-06-09 16:00:00', NOW(), NOW()),
(5, 9, 'Making', 'Firing', 'in_progress', 2, '2026-06-12 10:00:00', NULL, NOW(), NOW()),
(6, 10, 'Design', 'Confirm plan', 'completed', 1, '2026-06-11 10:00:00', '2026-06-10 14:00:00', NOW(), NOW()),
(7, 10, 'Making', 'Weaving', 'in_progress', 2, '2026-06-13 10:00:00', NULL, NOW(), NOW()),
(8, 11, 'Making Done', 'Ready to ship', 'completed', 2, '2026-06-12 10:00:00', '2026-06-12 11:00:00', NOW(), NOW()),
(9, 12, 'Making Done', 'Ready to ship', 'completed', 2, '2026-06-13 10:00:00', '2026-06-13 11:00:00', NOW(), NOW());

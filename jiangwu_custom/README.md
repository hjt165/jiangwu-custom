# 匠物定制 - Flutter 客户端

小众手作艺术品定制 APP，支持多模态交互、AI 推荐、3D 预览。

## 技术栈

- Flutter 3.x + Dart 3.x
- Riverpod 状态管理
- Dio 网络请求
- WebSocket 实时聊天

## 快速开始

```bash
# 获取依赖
flutter pub get

# 运行 Web 版本
flutter run -d chrome --web-port=8082

# 运行 Android 模拟器
flutter run

# 构建 Web 版本
flutter build web --no-tree-shake-icons
```

## 运行测试

```bash
# 测试（85 个）
flutter test

# 集成测试（需要后端运行中）
flutter test integration_test
```

## 项目结构

```
lib/
├── app/           # 应用配置（主题、路由、常量）
├── models/        # 数据模型
├── providers/     # 状态管理（Riverpod）
├── screens/       # 页面
├── services/      # 服务层（API、推送、支付等）
├── widgets/       # 可复用组件
└── utils/         # 工具类
```

## 测试账号

| 角色 | 手机号 | 密码 |
|------|--------|------|
| 管理员 | 13800000000 | admin123 |
| 普通用户 | 13800000001 | user123 |
| 手作人 | 13800000002 | artisan123 |

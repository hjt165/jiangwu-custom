# 匠物定制 - 项目启动指南

## 环境要求

| 组件 | 版本要求 |
|------|----------|
| JDK | 17+ |
| Maven | 3.8+ |
| Node.js | 18+ |
| Flutter | 3.x |
| MySQL | 8.0+ / 9.x |
| Redis | 6.0+ |

## 快速启动

### 1. 数据库

```bash
# 启动 MySQL（确保已安装）
# 创建数据库
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS jiangwu_custom DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 导入表结构
mysql -u root -p jiangwu_custom < server/src/main/resources/schema.sql

# 导入初始数据
mysql -u root -p jiangwu_custom < server/src/main/resources/data.sql
```

### 2. Redis

```bash
# 启动 Redis
redis-server
```

### 3. 后端服务

```bash
cd server

# 编译
mvn clean compile

# 运行测试
mvn test

# 启动服务（端口 8080）
mvn spring-boot:run
```

启动后访问：http://localhost:8080

### 4. 管理后台

```bash
cd admin

# 安装依赖
npm install

# 开发模式（端口 3000）
npm run dev

# 构建生产版本
npm run build
```

启动后访问：http://localhost:3000

### 5. Flutter 客户端

```bash
cd jiangwu_custom

# 获取依赖
flutter pub get

# 运行 Web 版本（端口 8082）
flutter run -d chrome --web-port=8082

# 运行 Android 模拟器
flutter run

# 构建 Web 版本
flutter build web --no-tree-shake-icons
```

## 测试账号

| 角色 | 手机号 | 密码 |
|------|--------|------|
| 管理员 | 13800000000 | admin123 |
| 普通用户 | 13800000001 | user123 |
| 手作人 | 13800000002 | artisan123 |

## 运行测试

```bash
# 后端测试（93 个）
cd server && mvn test

# Flutter 单元测试（46 个）
cd jiangwu_custom && flutter test

# Flutter 集成测试（需要后端运行中）
cd jiangwu_custom && flutter test integration_test
```

## 项目结构

```
app/
├── server/          # Spring Boot 后端
├── jiangwu_custom/  # Flutter 客户端
├── admin/           # Vue3 管理后台
├── ai-service/      # Python AI 服务
├── docs/            # 项目文档
└── docker-compose.yml
```

## 常见问题

### 后端启动失败
- 检查 MySQL 是否启动：`mysql -u root -p`
- 检查 Redis 是否启动：`redis-cli ping`
- 检查端口 8080 是否被占用

### Flutter 运行失败
- 运行 `flutter doctor` 检查环境
- 运行 `flutter clean && flutter pub get` 清理缓存

### 管理后台启动失败
- 运行 `rm -rf node_modules && npm install` 重装依赖

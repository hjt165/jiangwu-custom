# Loop Memory
> 记录历史修复模式，用于提升后续修复准确率

## 已知修复模式

### #FIX-001: Spring Boot Mock 不完整
- **模块**: server
- **错误类型**: ASSERTION_FAILURE
- **根因**: @MockBean 未覆盖新增的依赖注入
- **修复模板**: 检查 @MockBean 是否包含所有 @Autowired 字段
- **出现次数**: 0
- **最后出现**: -

### #FIX-002: Flutter Widget Test 缺少 ProviderScope
- **模块**: flutter
- **错误类型**: WIDGET_TEST_FAILURE
- **根因**: testWidgets() 未包裹 ProviderScope/Riverpod
- **修复模板**: 在 pumpWidget() 外层包裹 ProviderScope(child: MaterialApp(...))
- **出现次数**: 0
- **最后出现**: -

### #FIX-003: pytest Fixture 名称冲突
- **模块**: ai-service
- **错误类型**: DEPENDENCY_MISSING
- **根因**: conftest.py 中 fixture 名与测试文件局部 fixture 冲突
- **修复模板**: 重命名局部 fixture 或使用 @pytest.fixture(scope="session")
- **出现次数**: 0
- **最后出现**: -

### #FIX-004: MySQL 连接拒绝
- **模块**: server
- **错误类型**: CONFIGURATION_ERROR
- **根因**: 数据库未启动或连接参数错误
- **修复模板**: 检查 SPRING_DATASOURCE_URL 和 MySQL 服务状态
- **出现次数**: 0
- **最后出现**: -

### #FIX-005: Redis 连接超时
- **模块**: server
- **错误类型**: TIMEOUT
- **根因**: Redis 未启动或 host/port 配置错误
- **修复模板**: 检查 SPRING_DATA_REDIS_HOST 和 Redis 服务状态
- **出现次数**: 0
- **最后出现**: -

### #FIX-006: Flutter 集成测试键盘遮挡
- **模块**: flutter
- **错误类型**: ASSERTION_FAILURE
- **根因**: 真机测试时键盘未收起，按钮被遮挡
- **修复模板**: 在 tap 按钮前调用 dismissKeyboard() 收起键盘
- **出现次数**: 0
- **最后出现**: -

### #FIX-007: Playwright 元素不可点击
- **模块**: admin
- **错误类型**: ASSERTION_FAILURE
- **根因**: 元素被其他元素遮挡或不在视口中
- **修复模板**: 使用 page.scrollIntoViewIfNeeded() 或等待元素可见
- **出现次数**: 0
- **最后出现**: -

### #FIX-008: Flowable 工作流引擎初始化失败
- **模块**: server
- **错误类型**: DEPENDENCY_MISSING
- **根因**: Flowable 连接的数据库 Schema 未正确初始化
- **修复模板**: 确保 flowable 相关表已创建，检查 DATABASE_SCHEMA_UPDATE 配置
- **出现次数**: 0
- **最后出现**: -

## 修复成功率趋势

| 迭代 | 尝试修复 | 成功 | 失败 | 成功率 |
|-----|---------|------|------|--------|
| （等待首次运行） | - | - | - | - |

## 未解决问题（需人工介入）

（暂无）

## 环境依赖记录

- **server**: MySQL 8.0 + Redis 7 + RabbitMQ 3.12 + JDK 17
- **flutter**: Flutter 3.x stable + Dart 3.13
- **ai-service**: Python 3.11 + FastAPI + pytest
- **admin**: Node.js 20 + Playwright + Chromium
- **integration**: adb reverse tcp:8080 tcp:8080 (真机测试)

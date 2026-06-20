@echo off
echo 导入数据库表结构...
mysql -u root -p123456 jiangwu_custom < "%~dp0server\src\main\resources\schema.sql"
if errorlevel 1 (
    echo 导入失败，请检查 MySQL 是否已启动并添加到 PATH
    pause
)

@echo off
echo 启动 MySQL 服务...
echo 如果 mysql 不在 PATH 中，请先安装 MySQL 并添加到 PATH
mysqld --defaults-file="%~dp0mysql_config\my.ini"
if errorlevel 1 (
    echo MySQL 启动失败，请检查 MySQL 是否已安装并添加到 PATH
    pause
)

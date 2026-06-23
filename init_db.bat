@echo off
chcp 65001 >nul
set MYSQL_BIN="E:\MySQL\MySQL Server 9.4\bin\mysql.exe"
set SCHEMA="E:\桌面\app\server\src\main\resources\schema.sql"
set DATA="E:\桌面\app\server\src\main\resources\data.sql"
set INDEXES="E:\桌面\app\server\src\main\resources\db\indexes.sql"

%MYSQL_BIN% --default-character-set=utf8mb4 -u root -p123456 < %SCHEMA%
%MYSQL_BIN% --default-character-set=utf8mb4 -u root -p123456 jiangwu_custom < %DATA%
%MYSQL_BIN% --default-character-set=utf8mb4 -u root -p123456 jiangwu_custom < %INDEXES%

echo Database initialization complete.
pause
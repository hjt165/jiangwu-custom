@echo off
set JAVA_HOME=E:\??\app\jdk-17.0.2
set PATH=%JAVA_HOME%\bin;%PATH%
cd /d E:\??\app\server
java -jar target\jiangwu-server-1.0.0-SNAPSHOT.jar --spring.profiles.active=dev

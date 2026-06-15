# ========== Stage 1: Build ==========
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /build

# 先复制 pom.xml，利用 Docker 缓存加速依赖下载
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 复制源码并打包
COPY src ./src
RUN mvn package -DskipTests -B

# ========== Stage 2: Runtime ==========
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# 安装时区设置
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata

# 从构建阶段复制 jar
COPY --from=builder /build/target/*.jar app.jar

# 暴露端口
EXPOSE 8080

# 启动服务
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=docker"]

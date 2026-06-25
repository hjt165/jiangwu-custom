# Stage 1: 依赖安装
FROM python:3.11-slim AS builder

WORKDIR /app

# 安装系统依赖 (OpenCV + Milvus client)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件并安装
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: 运行时
FROM python:3.11-slim

WORKDIR /app

# 复制已安装的依赖
COPY --from=builder /install /usr/local

# 复制项目代码
COPY . .

# 创建非 root 用户 (Debian 方式)
RUN groupadd -r appgroup && useradd -r -g appgroup -d /app -s /sbin/nologin appuser && \
    chown -R appuser:appgroup /app
USER appuser

# 暴露端口
EXPOSE 8001

# 启动服务 (生产模式，不加 --reload)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "2"]

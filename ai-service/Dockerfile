FROM python:3.11-slim

WORKDIR /app

# 安装系统依赖 (OpenCV + Milvus client)
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目代码
COPY . .

# 创建非 root 用户
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
USER appuser

# 暴露端口
EXPOSE 8001

# 启动服务 (生产模式，不加 --reload)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "2"]

"""配置管理模块"""
import os
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """应用配置"""
    # 服务配置
    APP_NAME: str = "匠物定制 AI 服务"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    HOST: str = "0.0.0.0"
    PORT: int = 8001

    # CORS 配置
    CORS_ORIGINS: list[str] = ["http://localhost:3000", "http://localhost:8080"]

    # Qwen-VL API 配置 (DashScope OpenAI compatible)
    QWEN_API_KEY: str = os.getenv("QWEN_API_KEY", "mock-api-key")
    QWEN_API_BASE: str = os.getenv("QWEN_API_BASE", "https://dashscope.aliyuncs.com/compatible-mode/v1")
    QWEN_MODEL: str = "qwen-vl-max"
    QWEN_MAX_TOKENS: int = 4096
    QWEN_TEMPERATURE: float = 0.7

    # Milvus 向量数据库配置
    MILVUS_HOST: str = os.getenv("MILVUS_HOST", "localhost")
    MILVUS_PORT: int = int(os.getenv("MILVUS_PORT", "19530"))
    MILVUS_COLLECTION: str = "jiangwu_handcrafts"
    MILVUS_DIMENSION: int = 512  # CLIP embedding dimension

    # Spring Boot 后端回调配置
    SPRING_BOOT_URL: str = os.getenv("SPRING_BOOT_URL", "http://localhost:8080")

    # RabbitMQ 配置 (用于异步任务)
    RABBITMQ_HOST: str = os.getenv("RABBITMQ_HOST", "localhost")
    RABBITMQ_PORT: int = int(os.getenv("RABBITMQ_PORT", "5672"))
    RABBITMQ_USER: str = os.getenv("RABBITMQ_USER", "guest")
    RABBITMQ_PASSWORD: str = os.getenv("RABBITMQ_PASSWORD", "guest")
    RABBITMQ_VHOST: str = os.getenv("RABBITMQ_VHOST", "/")

    # Redis 配置 (用于结果缓存)
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/1")

    # 缓存配置
    CACHE_MAX_SIZE: int = 1000
    CACHE_TTL: int = 3600  # 1小时

    # 模型配置
    EMBEDDING_MODEL: str = "clip-vit-base"

    # 业务配置
    RECOMMEND_TOP_K: int = 10
    RAG_TOP_K: int = 5

    # 是否启用真实 LLM 调用 (False 时使用 Mock)
    ENABLE_REAL_LLM: bool = os.getenv("ENABLE_REAL_LLM", "false").lower() == "true"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()

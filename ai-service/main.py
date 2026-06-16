"""匠物定制 AI 服务 - FastAPI 入口"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from loguru import logger

from config import settings

# 全局客户端实例
_openai_client = None
_milvus_client = None
_redis_client = None


def get_openai_client():
    return _openai_client


def get_milvus_client():
    return _milvus_client


def get_redis_client():
    return _redis_client


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理"""
    global _openai_client, _milvus_client, _redis_client

    logger.info(f"{settings.APP_NAME} v{settings.APP_VERSION} 启动中...")

    # 初始化 OpenAI client (Qwen-VL)
    if settings.ENABLE_REAL_LLM:
        try:
            from openai import OpenAI
            _openai_client = OpenAI(
                api_key=settings.QWEN_API_KEY,
                base_url=settings.QWEN_API_BASE,
            )
            logger.info("OpenAI (Qwen-VL) client 初始化完成")
        except Exception as e:
            logger.error(f"OpenAI client 初始化失败: {e}")
            _openai_client = None
    else:
        logger.info("LLM 调用已禁用 (ENABLE_REAL_LLM=false)，使用 Mock 模式")

    # 初始化 Milvus 连接
    try:
        from pymilvus import MilvusClient
        _milvus_client = MilvusClient(
            uri=f"http://{settings.MILVUS_HOST}:{settings.MILVUS_PORT}"
        )
        # 检查 collection 是否存在，不存在则创建
        collections = _milvus_client.list_collections()
        if settings.MILVUS_COLLECTION not in collections:
            logger.info(f"Milvus collection '{settings.MILVUS_COLLECTION}' 不存在，开始创建...")
            try:
                from scripts.init_milvus import create_collection
                create_collection(_milvus_client)
            except Exception as e:
                logger.warning(f"Milvus collection 创建失败: {e}")
        else:
            logger.info(f"Milvus collection '{settings.MILVUS_COLLECTION}' 已存在")
    except Exception as e:
        logger.warning(f"Milvus 连接失败，RAG 检索将降级为 Mock 模式: {e}")
        _milvus_client = None

    # 初始化 Redis 连接
    try:
        import redis
        _redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
        _redis_client.ping()
        logger.info("Redis 连接完成")
    except Exception as e:
        logger.warning(f"Redis 连接失败，缓存功能不可用: {e}")
        _redis_client = None

    logger.info("AI 服务启动完成")

    yield

    # 关闭资源
    logger.info("AI 服务关闭中...")
    if _redis_client:
        try:
            _redis_client.close()
        except Exception as e:
            logger.warning(f"Redis关闭失败: {e}")
    if _milvus_client:
        try:
            _milvus_client.close()
        except Exception as e:
            logger.warning(f"Milvus关闭失败: {e}")
    logger.info("资源释放完成")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="匠物定制平台 AI 服务 - 多模态解析、RAG检索、智能推荐",
    lifespan=lifespan,
)

# CORS 中间件
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
from api.routes import router
app.include_router(router, prefix="/api/ai")


@app.get("/")
async def root():
    return {
        "name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running",
    }

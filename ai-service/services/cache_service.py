"""缓存服务 - 内存 LRU 缓存"""
from cachetools import TTLCache
from loguru import logger

from config import settings


class CacheService:
    """缓存服务"""

    def __init__(self):
        self._cache = TTLCache(
            maxsize=settings.CACHE_MAX_SIZE,
            ttl=settings.CACHE_TTL,
        )
        logger.info(f"CacheService 初始化: maxsize={settings.CACHE_MAX_SIZE}, ttl={settings.CACHE_TTL}s")

    def get(self, key: str):
        """获取缓存"""
        value = self._cache.get(key)
        if value is not None:
            logger.debug(f"缓存命中: {key}")
        return value

    def set(self, key: str, value, ttl: int = None):
        """设置缓存"""
        self._cache[key] = value
        logger.debug(f"缓存设置: {key}")

    def delete(self, key: str):
        """删除缓存"""
        self._cache.pop(key, None)
        logger.debug(f"缓存删除: {key}")

    def clear(self):
        """清空缓存"""
        self._cache.clear()
        logger.info("缓存已清空")

    @property
    def size(self) -> int:
        return len(self._cache)


# 全局缓存实例
cache_service = CacheService()
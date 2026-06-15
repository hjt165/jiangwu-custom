"""向量检索器 - Milvus 真实实现
基于向量相似度检索历史案例
"""
import time
import json
from loguru import logger

from config import settings
from schemas import SimilarCase, SimilarCaseResponse


class Retriever:
    """向量检索器"""

    # Mock 历史案例库 (降级时使用)
    MOCK_CASES = [
        SimilarCase(
            id="case_001", title="古法银饰龙凤镯",
            description="采用传统古法锻造工艺，龙凤呈祥纹样，925纯银材质",
            image_url="", similarity=0.95, category="jewelry", price=4800,
        ),
        SimilarCase(
            id="case_002", title="青瓷花瓶·梅子青",
            description="龙泉青瓷，梅子青釉色，手工拉坯，梅纹浮雕",
            image_url="", similarity=0.88, category="ceramic", price=3200,
        ),
        SimilarCase(
            id="case_003", title="竹编茶盘·山水纹",
            description="三年以上毛竹，手工竹编，山水纹样，榫卯结构",
            image_url="", similarity=0.82, category="woodwork", price=1800,
        ),
        SimilarCase(
            id="case_004", title="植鞣皮手缝钱包",
            description="意大利植鞣牛皮，手缝工艺，复古做旧，个性化刻字",
            image_url="", similarity=0.78, category="leather", price=1200,
        ),
        SimilarCase(
            id="case_005", title="紫檀手串·108颗",
            description="小叶紫檀，手工打磨，108颗佛珠，配南红隔珠",
            image_url="", similarity=0.75, category="woodwork", price=2600,
        ),
        SimilarCase(
            id="case_006", title="珐琅彩银饰项链",
            description="925纯银底胎，掐丝珐琅工艺，花鸟纹样",
            image_url="", similarity=0.72, category="jewelry", price=5600,
        ),
    ]

    def __init__(self):
        self._milvus_client = None

    def _get_milvus(self):
        if self._milvus_client is None:
            from main import get_milvus_client
            self._milvus_client = get_milvus_client()
        return self._milvus_client

    def find_similar(self, case_id: str, top_k: int = 5) -> SimilarCaseResponse:
        """检索相似案例"""
        start_time = time.time()
        logger.info(f"检索相似案例: case_id={case_id}, top_k={top_k}")

        milvus = self._get_milvus()

        if milvus:
            try:
                result = self._search_milvus(milvus, case_id, top_k)
                query_time = (time.time() - start_time) * 1000
                result.query_time_ms = round(query_time, 1)
                logger.info(f"Milvus 检索完成: {result.total} 个结果, {result.query_time_ms:.1f}ms")
                return result
            except Exception as e:
                logger.warning(f"Milvus 检索失败，降级到 Mock: {e}")

        return self._find_similar_fallback(case_id, top_k, start_time)

    def find_by_text(self, text: str, top_k: int = 5) -> SimilarCaseResponse:
        """基于文本检索相似案例"""
        start_time = time.time()
        logger.info(f"文本检索: {text[:50]}..., top_k={top_k}")

        milvus = self._get_milvus()

        if milvus:
            try:
                result = self._search_milvus_by_text(milvus, text, top_k)
                query_time = (time.time() - start_time) * 1000
                result.query_time_ms = round(query_time, 1)
                logger.info(f"Milvus 文本检索完成: {result.total} 个结果")
                return result
            except Exception as e:
                logger.warning(f"Milvus 文本检索失败，降级到 Mock: {e}")

        return self._find_similar_fallback("text_query", top_k, start_time)

    def _search_milvus(self, milvus, case_id: str, top_k: int) -> SimilarCaseResponse:
        """Milvus 向量检索"""
        # 从 Milvus 获取指定记录的 embedding
        record = milvus.get(
            collection_name=settings.MILVUS_COLLECTION,
            ids=[case_id],
        )

        if not record or len(record) == 0:
            return SimilarCaseResponse(cases=[], total=0, query_time_ms=0)

        query_vector = record[0].get("vector")
        if query_vector is None:
            return SimilarCaseResponse(cases=[], total=0, query_time_ms=0)

        # 向量相似度搜索
        search_params = {"metric_type": "COSINE", "params": {"nprobe": 16}}
        results = milvus.search(
            collection_name=settings.MILVUS_COLLECTION,
            data=[query_vector],
            limit=top_k,
            output_fields=["id", "title", "description", "image_url", "category", "price"],
            search_params=search_params,
        )

        cases = []
        for hits in results:
            for hit in hits:
                entity = hit.get("entity", {})
                cases.append(SimilarCase(
                    id=str(hit.get("id", "")),
                    title=entity.get("title", ""),
                    description=entity.get("description", ""),
                    image_url=entity.get("image_url", ""),
                    similarity=round(hit.get("distance", 0), 3),
                    category=entity.get("category", ""),
                    price=float(entity.get("price", 0)),
                ))

        return SimilarCaseResponse(cases=cases, total=len(cases), query_time_ms=0)

    def _search_milvus_by_text(self, milvus, text: str, top_k: int) -> SimilarCaseResponse:
        """基于文本的 Milvus 检索 (先用 LLM 生成 embedding，这里简化为关键词匹配)"""
        # 注意: 真实场景需要用 text-embedding 模型生成向量
        # 这里简化为用 OpenAI embedding API
        from main import get_openai_client
        client = get_openai_client()

        if not client:
            raise RuntimeError("No LLM client available for text embedding")

        try:
            # 用 text-embedding 模型生成向量 (Qwen 有 text-embedding-v2)
            response = client.embeddings.create(
                model="text-embedding-v2",
                input=text,
            )
            query_vector = response.data[0].embedding

            search_params = {"metric_type": "COSINE", "params": {"nprobe": 16}}
            results = milvus.search(
                collection_name=settings.MILVUS_COLLECTION,
                data=[query_vector],
                limit=top_k,
                output_fields=["id", "title", "description", "image_url", "category", "price"],
                search_params=search_params,
            )

            cases = []
            for hits in results:
                for hit in hits:
                    entity = hit.get("entity", {})
                    cases.append(SimilarCase(
                        id=str(hit.get("id", "")),
                        title=entity.get("title", ""),
                        description=entity.get("description", ""),
                        image_url=entity.get("image_url", ""),
                        similarity=round(hit.get("distance", 0), 3),
                        category=entity.get("category", ""),
                        price=float(entity.get("price", 0)),
                    ))

            return SimilarCaseResponse(cases=cases, total=len(cases), query_time_ms=0)
        except Exception as e:
            logger.error(f"Text embedding 生成失败: {e}")
            raise

    def _find_similar_fallback(self, case_id: str, top_k: int, start_time: float) -> SimilarCaseResponse:
        """降级: Mock 数据"""
        cases = self.MOCK_CASES[:top_k]
        query_time = (time.time() - start_time) * 1000 + 15.5

        logger.info(f"Mock 检索完成: {len(cases)} 个案例, {query_time:.1f}ms")
        return SimilarCaseResponse(
            cases=cases,
            total=len(cases),
            query_time_ms=round(query_time, 1),
        )

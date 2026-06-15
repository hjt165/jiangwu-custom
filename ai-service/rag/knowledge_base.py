"""知识库管理 - 真实实现
手作工艺知识库 + Milvus 检索
"""
import json
from loguru import logger

from config import settings


class KnowledgeBase:
    """手作工艺知识库"""

    # 基础知识条目 (始终保留作为兜底)
    KNOWLEDGE_ITEMS = {
        "jewelry": {
            "materials": [
                {"name": "925纯银", "properties": "硬度适中，光泽好，易氧化需保养", "price_range": "5-15元/克"},
                {"name": "足金999", "properties": "纯度高，柔软，保值", "price_range": "400-500元/克"},
                {"name": "天然翡翠", "properties": "硬度高，色泽温润", "price_range": "100-100000元/件"},
            ],
            "techniques": [
                {"name": "古法锻造", "description": "传统手工锤打成型，质感厚重", "difficulty": "高", "time": "7-15天"},
                {"name": "精密铸造", "description": "失蜡法铸造，细节精细", "difficulty": "中", "time": "5-10天"},
                {"name": "珐琅工艺", "description": "掐丝填釉，色彩丰富", "difficulty": "高", "time": "10-20天"},
            ],
        },
        "ceramic": {
            "materials": [
                {"name": "高岭土", "properties": "质地细腻，白度高", "price_range": "2-5元/公斤"},
                {"name": "紫砂泥", "properties": "透气性好，适合茶具", "price_range": "50-500元/公斤"},
            ],
            "techniques": [
                {"name": "拉坯成型", "description": "转盘手工拉坯，器型规整", "difficulty": "中", "time": "3-7天"},
                {"name": "釉下彩", "description": "素坯上绘画后罩釉烧制", "difficulty": "高", "time": "7-14天"},
            ],
        },
        "leather": {
            "materials": [
                {"name": "意大利植鞣皮", "properties": "环保鞣制，随时间变色", "price_range": "30-80元/平方尺"},
                {"name": "法国小牛皮", "properties": "皮质细腻，柔软", "price_range": "50-120元/平方尺"},
            ],
            "techniques": [
                {"name": "手缝工艺", "description": "双针手缝，牢固耐用", "difficulty": "中", "time": "5-10天"},
                {"name": "植鞣革塑形", "description": "湿模塑形，立体感强", "difficulty": "高", "time": "7-14天"},
            ],
        },
        "woodwork": {
            "materials": [
                {"name": "小叶紫檀", "properties": "密度高，油性好，珍贵", "price_range": "500-2000元/公斤"},
                {"name": "黄花梨", "properties": "纹理美，香味持久", "price_range": "1000-5000元/公斤"},
            ],
            "techniques": [
                {"name": "榫卯结构", "description": "无钉无胶，传统连接", "difficulty": "高", "time": "10-30天"},
                {"name": "浮雕", "description": "平面雕刻，层次分明", "difficulty": "中", "time": "7-15天"},
            ],
        },
    }

    def __init__(self):
        self._milvus_client = None
        logger.info("KnowledgeBase 初始化完成")

    def _get_milvus(self):
        if self._milvus_client is None:
            from main import get_milvus_client
            self._milvus_client = get_milvus_client()
        return self._milvus_client

    def get_knowledge(self, category: str) -> dict:
        """获取品类知识"""
        return self.KNOWLEDGE_ITEMS.get(category, {})

    def search(self, query: str, top_k: int = 5) -> list:
        """搜索知识条目"""
        # 先从本地知识库搜索
        results = []
        for category, items in self.KNOWLEDGE_ITEMS.items():
            for sub_items in items.values():
                for item in sub_items:
                    if query.lower() in item.get("name", "").lower():
                        results.append(item)

        # 如果有 Milvus，补充向量检索结果
        milvus = self._get_milvus()
        if milvus and len(results) < top_k:
            try:
                from main import get_openai_client
                client = get_openai_client()
                if client:
                    response = client.embeddings.create(
                        model="text-embedding-v2",
                        input=query,
                    )
                    query_vector = response.data[0].embedding

                    search_params = {"metric_type": "COSINE", "params": {"nprobe": 16}}
                    search_results = milvus.search(
                        collection_name=settings.MILVUS_COLLECTION,
                        data=[query_vector],
                        limit=top_k - len(results),
                        output_fields=["title", "description", "category"],
                        search_params=search_params,
                    )

                    for hits in search_results:
                        for hit in hits:
                            entity = hit.get("entity", {})
                            results.append({
                                "name": entity.get("title", ""),
                                "description": entity.get("description", ""),
                                "category": entity.get("category", ""),
                                "similarity": round(hit.get("distance", 0), 3),
                            })
            except Exception as e:
                logger.warning(f"Milvus 知识搜索失败: {e}")

        return results[:top_k]

    def get_techniques_for_category(self, category: str) -> list:
        """获取品类相关技法"""
        knowledge = self.get_knowledge(category)
        return knowledge.get("techniques", [])

    def get_materials_for_category(self, category: str) -> list:
        """获取品类相关材料"""
        knowledge = self.get_knowledge(category)
        return knowledge.get("materials", [])

"""Milvus 初始化 + 数据导入脚本
从 Spring Boot 拉取历史数据，生成 embedding 并导入 Milvus
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import httpx
from pymilvus import MilvusClient, DataType, CollectionSchema, FieldSchema
from loguru import logger

from config import settings


def create_collection(client: MilvusClient):
    """创建 Milvus collection"""
    collection_name = settings.MILVUS_COLLECTION

    # 检查是否已存在
    collections = client.list_collections()
    if collection_name in collections:
        logger.info(f"Collection '{collection_name}' 已存在，跳过创建")
        return

    # 定义 schema
    fields = [
        FieldSchema(name="id", dtype=DataType.VARCHAR, is_primary=True, max_length=64),
        FieldSchema(name="title", dtype=DataType.VARCHAR, max_length=256),
        FieldSchema(name="description", dtype=DataType.VARCHAR, max_length=2048),
        FieldSchema(name="image_url", dtype=DataType.VARCHAR, max_length=512),
        FieldSchema(name="category", dtype=DataType.VARCHAR, max_length=64),
        FieldSchema(name="price", dtype=DataType.FLOAT),
        FieldSchema(name="vector", dtype=DataType.FLOAT_VECTOR, dim=settings.MILVUS_DIMENSION),
    ]

    schema = CollectionSchema(fields=fields, description="匠物定制手作品向量库")

    # 创建 collection
    client.create_collection(
        collection_name=collection_name,
        schema=schema,
    )

    # 创建索引
    index_params = client.prepare_index_params()
    index_params.add_index(
        field_name="vector",
        metric_type="COSINE",
        params={"nlist": 128},
    )
    client.create_index(collection_name=collection_name, index_params=index_params)

    logger.info(f"Collection '{collection_name}' 创建完成")


def fetch_products_from_backend() -> list:
    """从 Spring Boot 获取历史作品"""
    try:
        with httpx.Client(timeout=15.0) as client:
            url = f"{settings.SPRING_BOOT_URL}/api/product/list"
            resp = client.get(url, params={"page": 1, "size": 200})
            resp.raise_for_status()
            data = resp.json()
            products = data.get("data", {}).get("records", [])
            logger.info(f"从后端获取 {len(products)} 个作品")
            return products
    except Exception as e:
        logger.warning(f"从后端获取作品失败: {e}")
        return []


def generate_embedding(client, text: str) -> list:
    """用 OpenAI embedding API 生成向量"""
    try:
        response = client.embeddings.create(
            model="text-embedding-v2",
            input=text,
        )
        return response.data[0].embedding
    except Exception as e:
        logger.warning(f"Embedding 生成失败: {e}")
        # 返回随机向量作为降级
        import random
        return [random.random() for _ in range(settings.MILVUS_DIMENSION)]


def import_data(milvus_client: MilvusClient):
    """导入数据到 Milvus"""
    collection_name = settings.MILVUS_COLLECTION

    # 检查是否已有数据
    stats = milvus_client.get_collection_stats(collection_name)
    if stats.get("row_count", 0) > 0:
        logger.info(f"Collection 已有 {stats['row_count']} 条数据，跳过导入")
        return

    # 从后端获取作品
    products = fetch_products_from_backend()
    if not products:
        logger.info("没有作品数据可导入")
        return

    # 生成 embedding 并导入
    from main import get_openai_client
    openai_client = get_openai_client()

    data = []
    for p in products:
        product_id = str(p.get("id", ""))
        title = p.get("title", "")
        description = p.get("description", "")
        cover_image = p.get("coverImage", "")
        category = p.get("category", "")
        price = float(p.get("price", 0))

        # 生成 embedding
        text_for_embedding = f"{title} {description} {category}"
        if openai_client:
            vector = generate_embedding(openai_client, text_for_embedding)
        else:
            import random
            vector = [random.random() for _ in range(settings.MILVUS_DIMENSION)]

        data.append({
            "id": product_id,
            "title": title,
            "description": description[:2048],
            "image_url": cover_image[:512] if cover_image else "",
            "category": category,
            "price": price,
            "vector": vector,
        })

    # 批量插入
    batch_size = 100
    for i in range(0, len(data), batch_size):
        batch = data[i:i + batch_size]
        milvus_client.insert(
            collection_name=collection_name,
            data=batch,
        )
        logger.info(f"导入第 {i+1}-{min(i+batch_size, len(data))} 条数据")

    logger.info(f"共导入 {len(data)} 条数据到 Milvus")


def main():
    """主函数"""
    logger.info("开始 Milvus 初始化...")

    try:
        client = MilvusClient(
            uri=f"http://{settings.MILVUS_HOST}:{settings.MILVUS_PORT}"
        )
    except Exception as e:
        logger.error(f"Milvus 连接失败: {e}")
        return

    # 创建 collection
    create_collection(client)

    # 导入数据
    import_data(client)

    # 关闭
    client.close()
    logger.info("Milvus 初始化完成")


if __name__ == "__main__":
    main()

"""多模态解析服务 - 真实实现
串联 image_analyzer + text_analyzer + fusion
"""
import httpx
from loguru import logger

from config import settings
from schemas import (
    ImageAnalysisResponse,
    TextAnalysisResponse,
    MultimodalAnalysisResponse,
)
from multimodal.image_analyzer import ImageAnalyzer
from multimodal.text_analyzer import TextAnalyzer
from multimodal.fusion import MultimodalFusion


class AnalysisService:
    """多模态解析服务"""

    def __init__(self):
        self.image_analyzer = ImageAnalyzer()
        self.text_analyzer = TextAnalyzer()
        self.fusion = MultimodalFusion()
        logger.info("AnalysisService 初始化完成")

    def analyze_image(
        self,
        image_data: bytes,
        filename: str = "",
        description: str = None,
    ) -> ImageAnalysisResponse:
        """分析图片 - 提取颜色、风格、元素"""
        logger.info(f"分析图片: {filename}, 大小: {len(image_data)} bytes")
        result = self.image_analyzer.analyze(image_data, filename)
        logger.info(f"图片分析完成: {len(result.colors)} 个颜色, {len(result.style_tags)} 个标签")
        return result

    def analyze_text(
        self,
        text: str,
        category: str = None,
    ) -> TextAnalysisResponse:
        """分析文字 - 意图识别、关键词提取"""
        logger.info(f"分析文字: {text[:50]}...")
        result = self.text_analyzer.analyze(text, category)
        logger.info(f"文字分析完成: {len(result.intents)} 个意图, {len(result.keywords)} 个关键词")
        return result

    def analyze_multimodal(
        self,
        image_data: bytes = None,
        text: str = None,
        category: str = None,
    ) -> MultimodalAnalysisResponse:
        """多模态联合分析"""
        logger.info(f"多模态分析: image={image_data is not None}, text={text is not None}")

        image_result = None
        text_result = None

        if image_data is not None:
            image_result = self.image_analyzer.analyze(image_data)

        if text is not None:
            text_result = self.text_analyzer.analyze(text, category)

        result = self.fusion.fuse(
            image_result=image_result,
            text_result=text_result,
            category=category,
            image_data=image_data,
        )

        logger.info(f"多模态分析完成: 置信度={result.confidence:.2f}")
        return result

    async def get_artisan_list_from_backend(self, category: str = None) -> list:
        """从 Spring Boot 获取手作人列表"""
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                url = f"{settings.SPRING_BOOT_URL}/api/artisan/list"
                params = {}
                if category:
                    params["category"] = category
                resp = await client.get(url, params=params)
                resp.raise_for_status()
                data = resp.json()
                return data.get("data", [])
        except Exception as e:
            logger.warning(f"从后端获取手作人列表失败: {e}")
            return []

    async def get_product_list_from_backend(self, category: str = None) -> list:
        """从 Spring Boot 获取作品列表"""
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                url = f"{settings.SPRING_BOOT_URL}/api/product/list"
                params = {"page": 1, "size": 50}
                if category:
                    params["category"] = category
                resp = await client.get(url, params=params)
                resp.raise_for_status()
                data = resp.json()
                return data.get("data", {}).get("records", [])
        except Exception as e:
            logger.warning(f"从后端获取作品列表失败: {e}")
            return []

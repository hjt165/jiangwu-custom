"""跨模态特征融合 - 真实 Qwen-VL 实现
将图片和文字分析结果融合为统一的需求表
"""
import base64
import json
from loguru import logger

from config import settings
from schemas import (
    ImageAnalysisResponse,
    TextAnalysisResponse,
    MultimodalAnalysisResponse,
    RequirementSheet,
)
from rag.prompt_templates import PromptTemplates


class MultimodalFusion:
    """跨模态特征融合器"""

    # Mock 数据 (降级时使用)
    MATERIAL_MAP = {
        "jewelry": ["925纯银", "足金", "天然宝石", "珍珠"],
        "leather": ["意大利植鞣皮", "法国小牛皮", "日本疯马皮"],
        "ceramic": ["高岭土", "紫砂泥", "瓷土"],
        "woodwork": ["小叶紫檀", "黄花梨", "金丝楠木"],
    }

    TECHNIQUE_MAP = {
        "jewelry": ["古法锻造", "精密铸造", "珐琅工艺", "镶嵌"],
        "leather": ["手缝工艺", "植鞣革塑形", "烫金", "雕刻"],
        "ceramic": ["拉坯成型", "手工捏塑", "釉下彩", "窑变"],
        "woodwork": ["榫卯结构", "浮雕", "圆雕", "透雕"],
    }

    def __init__(self):
        self._client = None

    def _get_client(self):
        if self._client is None:
            from main import get_openai_client
            self._client = get_openai_client()
        return self._client

    def fuse(
        self,
        image_result: ImageAnalysisResponse = None,
        text_result: TextAnalysisResponse = None,
        category: str = None,
        image_data: bytes = None,
    ) -> MultimodalAnalysisResponse:
        """融合分析结果"""
        logger.info("开始多模态融合分析")

        client = self._get_client()

        if settings.ENABLE_REAL_LLM and client and (image_data or image_result or text_result):
            return self._fuse_with_llm(client, image_result, text_result, category, image_data)

        return self._fuse_fallback(image_result, text_result, category)

    def _fuse_with_llm(
        self,
        client,
        image_result: ImageAnalysisResponse = None,
        text_result: TextAnalysisResponse = None,
        category: str = None,
        image_data: bytes = None,
    ) -> MultimodalAnalysisResponse:
        """用 Qwen-VL 真实融合分析"""
        prompt = PromptTemplates.SOLUTION_GENERATION

        # 构建上下文
        context_parts = []
        if image_result:
            context_parts.append(f"图片分析: 风格={image_result.style_tags}, 元素={[e.name for e in image_result.elements]}, 氛围={image_result.mood}")
        if text_result:
            context_parts.append(f"文字分析: 品类={text_result.category}, 关键词={text_result.keywords}, 需求={text_result.requirements}")
        if category:
            context_parts.append(f"用户指定品类: {category}")

        user_input = "\n".join(context_parts) if context_parts else "无具体需求"
        prompt_text = PromptTemplates.format_template(
            "REQUIREMENT_UNDERSTANDING",
            user_input=user_input,
        )

        messages = []
        if image_data:
            b64 = base64.b64encode(image_data).decode("utf-8")
            messages.append({
                "role": "user",
                "content": [
                    {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{b64}"}},
                    {"type": "text", "text": prompt_text + "\n\n请以 JSON 格式返回：{\"category\": \"品类\", \"style\": \"风格\", \"materials\": [\"材料\"], \"techniques\": [\"技法\"], \"description\": \"描述\", \"budget_range\": \"预算范围\"}"},
                ],
            })
        else:
            messages.append({"role": "user", "content": prompt_text + "\n\n请以 JSON 格式返回：{\"category\": \"品类\", \"style\": \"风格\", \"materials\": [\"材料\"], \"techniques\": [\"技法\"], \"description\": \"描述\", \"budget_range\": \"预算范围\"}"})

        try:
            response = client.chat.completions.create(
                model=settings.QWEN_MODEL,
                messages=messages,
                max_tokens=settings.QWEN_MAX_TOKENS,
                temperature=settings.QWEN_TEMPERATURE,
            )

            content = response.choices[0].message.content
            data = self._parse_json_from_text(content)

            detected_category = data.get("category", category or "jewelry")
            style = data.get("style", "古典")
            materials = data.get("materials", self.MATERIAL_MAP.get(detected_category, ["925纯银"])[:3])
            techniques = data.get("techniques", self.TECHNIQUE_MAP.get(detected_category, ["古法锻造"])[:3])
            description = data.get("description", "")
            budget_range = data.get("budget_range", "2000-5000")

            # 构建参考元素
            ref_elements = []
            if image_result and image_result.elements:
                ref_elements = [e.name for e in image_result.elements[:3]]

            requirement_sheet = RequirementSheet(
                title=f"定制{detected_category}手作品",
                category=detected_category,
                description=description,
                materials=materials,
                techniques=techniques,
                style=style,
                budget_range=budget_range,
                reference_elements=ref_elements,
            )

            confidence = 0.9
            if image_result and text_result:
                confidence = (image_result.confidence + text_result.confidence) / 2

            summary_parts = []
            if text_result:
                summary_parts.append(text_result.summary)
            if image_result:
                summary_parts.append(image_result.summary)
            summary = " ".join(summary_parts) or f"已生成{style}风格{detected_category}定制需求表"

            logger.info(f"LLM 多模态融合完成: 品类={detected_category}, 风格={style}")
            return MultimodalAnalysisResponse(
                requirement_sheet=requirement_sheet,
                image_analysis=image_result,
                text_analysis=text_result,
                confidence=round(confidence, 2),
                summary=summary,
            )
        except Exception as e:
            logger.error(f"LLM 融合分析失败，降级到 Mock: {e}")
            return self._fuse_fallback(image_result, text_result, category)

    def _fuse_fallback(
        self,
        image_result: ImageAnalysisResponse = None,
        text_result: TextAnalysisResponse = None,
        category: str = None,
    ) -> MultimodalAnalysisResponse:
        """降级: 基于规则的 Mock 融合"""
        detected_category = category or "jewelry"
        if text_result and text_result.category:
            detected_category = text_result.category

        materials = self.MATERIAL_MAP.get(detected_category, self.MATERIAL_MAP["jewelry"])
        techniques = self.TECHNIQUE_MAP.get(detected_category, self.TECHNIQUE_MAP["jewelry"])

        style = "古典"
        if image_result and image_result.style_tags:
            style = image_result.style_tags[0]
        if text_result and text_result.requirements.get("style"):
            style = text_result.requirements["style"]

        description = ""
        if text_result:
            description = text_result.summary
        if image_result:
            description = f"{description} {image_result.summary}".strip()

        requirement_sheet = RequirementSheet(
            title=f"定制{detected_category}手作品",
            category=detected_category,
            description=description or f"定制一件{style}风格的{detected_category}手作品",
            materials=materials[:3],
            techniques=techniques[:3],
            style=style,
            budget_range=text_result.requirements.get("budget_range", "2000-5000") if text_result else "2000-5000",
            reference_elements=[e.name for e in image_result.elements[:3]] if image_result else [],
        )

        confidence = 0.85
        if image_result and text_result:
            confidence = (image_result.confidence + text_result.confidence) / 2
        elif image_result:
            confidence = image_result.confidence
        elif text_result:
            confidence = text_result.confidence

        summary_parts = []
        if text_result:
            summary_parts.append(text_result.summary)
        if image_result:
            summary_parts.append(image_result.summary)
        summary = " ".join(summary_parts) or f"已生成{style}风格{detected_category}定制需求表"

        return MultimodalAnalysisResponse(
            requirement_sheet=requirement_sheet,
            image_analysis=image_result,
            text_analysis=text_result,
            confidence=round(confidence, 2),
            summary=summary,
        )

    def _parse_json_from_text(self, text: str) -> dict:
        """从 LLM 输出中提取 JSON"""
        try:
            start = text.find("{")
            end = text.rfind("}") + 1
            if start >= 0 and end > start:
                return json.loads(text[start:end])
        except json.JSONDecodeError as e:
            logger.warning(f"JSON解析失败: {e}, 原始文本: {text[:200]}")
        return {}

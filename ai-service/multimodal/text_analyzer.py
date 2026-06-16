"""文字分析器 - 真实 Qwen-VL 实现
意图识别、关键词提取、需求结构化
"""
import base64
import hashlib
import json
from loguru import logger

from config import settings
from schemas import TextAnalysisResponse, IntentResult
from rag.prompt_templates import PromptTemplates


class TextAnalyzer:
    """文字分析器"""

    # Mock 数据 (降级时使用)
    MOCK_INTENTS = [
        IntentResult(intent="定制银饰", confidence=0.95, parameters={"category": "jewelry", "material": "silver"}),
        IntentResult(intent="定制皮具", confidence=0.88, parameters={"category": "leather", "material": "leather"}),
        IntentResult(intent="定制陶瓷", confidence=0.82, parameters={"category": "ceramic", "material": "ceramic"}),
        IntentResult(intent="定制木雕", confidence=0.78, parameters={"category": "woodwork", "material": "wood"}),
    ]

    MOCK_KEYWORDS = {
        "jewelry": ["银饰", "戒指", "项链", "手镯", "耳环", "吊坠", "古法", "锻造"],
        "leather": ["皮具", "钱包", "手包", "皮带", "植鞣", "手缝", "定制"],
        "ceramic": ["陶瓷", "茶杯", "花瓶", "青瓷", "釉色", "手捏", "烧制"],
        "woodwork": ["木雕", "摆件", "手串", "茶盘", "榫卯", "雕刻", "红木"],
    }

    def __init__(self):
        self._client = None

    def _get_client(self):
        if self._client is None:
            from main import get_openai_client
            self._client = get_openai_client()
        return self._client

    def analyze(self, text: str, category: str = None) -> TextAnalysisResponse:
        """分析文字"""
        logger.info(f"文字分析: {text[:50]}...")

        client = self._get_client()

        if settings.ENABLE_REAL_LLM and client:
            return self._analyze_with_llm(client, text, category)

        return self._analyze_fallback(text, category)

    def _analyze_with_llm(self, client, text: str, category: str = None) -> TextAnalysisResponse:
        """用 Qwen-VL 真实分析文字"""
        prompt = PromptTemplates.format_template("REQUIREMENT_UNDERSTANDING", user_input=text)
        json_hint = (
            "\n\n请以 JSON 格式返回："
            '{"intents": [{"intent": "意图", "confidence": 0.9, "parameters": {}}], '
            '"keywords": ["关键词"], "category": "jewelry/leather/ceramic/woodwork/painting/other", '
            '"requirements": {"style": "风格", "budget_range": "1000-3000", "material": "材质", "delivery_days": "15"}}'
        )

        try:
            response = client.chat.completions.create(
                model=settings.QWEN_MODEL,
                messages=[{"role": "user", "content": prompt + json_hint}],
                max_tokens=settings.QWEN_MAX_TOKENS,
                temperature=settings.QWEN_TEMPERATURE,
            )

            content = response.choices[0].message.content
            data = self._parse_json_from_text(content)

            intents = [IntentResult(**i) for i in data.get("intents", [])]
            keywords = data.get("keywords", [])
            detected_category = data.get("category", category or "jewelry")
            requirements = data.get("requirements", {})

            summary = f"检测到您想定制{detected_category}类手作品"
            if requirements.get("style"):
                summary += f"，偏好{requirements['style']}风格"

            logger.info(f"LLM 文字分析完成: {len(intents)} 意图, {len(keywords)} 关键词")
            return TextAnalysisResponse(
                intents=intents,
                keywords=keywords,
                category=detected_category,
                requirements=requirements,
                summary=summary,
                confidence=0.9,
            )
        except Exception as e:
            logger.error(f"LLM 文字分析失败，降级到 Mock: {e}")
            return self._analyze_fallback(text, category)

    def _analyze_fallback(self, text: str, category: str = None) -> TextAnalysisResponse:
        """降级: 基于关键词匹配的 Mock 分析"""
        seed = hashlib.md5(text.encode()).hexdigest()[:8]

        detected_category = category or "jewelry"
        for cat, keywords in self.MOCK_KEYWORDS.items():
            for kw in keywords:
                if kw in text:
                    detected_category = cat
                    break

        intents = [i for i in self.MOCK_INTENTS if i.parameters.get("category") == detected_category]
        if not intents:
            intents = self.MOCK_INTENTS[:2]

        keywords = self.MOCK_KEYWORDS.get(detected_category, self.MOCK_KEYWORDS["jewelry"])[:5]

        requirements = {
            "category": detected_category,
            "style": "古典" if "古" in text else "现代",
            "budget_range": "2000-5000" if "预算" in text else "1000-3000",
            "priority": "品质" if "精致" in text else "性价比",
        }

        confidence = 0.75 + (int(seed[:2], 16) % 25) / 100

        return TextAnalysisResponse(
            intents=intents,
            keywords=keywords,
            category=detected_category,
            requirements=requirements,
            summary=f"检测到您想定制{detected_category}类手作品，偏好{requirements['style']}风格",
            confidence=round(confidence, 2),
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

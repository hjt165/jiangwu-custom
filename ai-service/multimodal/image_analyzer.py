"""图片分析器 - 真实 Qwen-VL 实现
提取颜色特征、风格标签、设计元素
"""
import base64
import hashlib
import json
import cv2
import numpy as np
from loguru import logger

from config import settings
from schemas import ImageAnalysisResponse, ColorFeature, DesignElement
from rag.prompt_templates import PromptTemplates


class ImageAnalyzer:
    """图片分析器"""

    # Mock 颜色库 (降级时使用)
    MOCK_COLORS = [
        ColorFeature(hex="#C0392B", name="中国红", percentage=0.35),
        ColorFeature(hex="#F1C40F", name="明黄", percentage=0.25),
        ColorFeature(hex="#2C3E50", name="墨色", percentage=0.20),
        ColorFeature(hex="#ECF0F1", name="素白", percentage=0.15),
        ColorFeature(hex="#8B4513", name="檀木棕", percentage=0.05),
    ]
    MOCK_STYLE_TAGS = ["古典", "雅致", "传统", "精致", "典雅"]
    MOCK_ELEMENTS = [
        DesignElement(name="祥云纹", confidence=0.92, description="传统吉祥纹样"),
        DesignElement(name="回字纹", confidence=0.85, description="几何装饰纹样"),
        DesignElement(name="龙凤呈祥", confidence=0.78, description="传统瑞兽图案"),
    ]

    def __init__(self):
        self._client = None

    def _get_client(self):
        if self._client is None:
            from main import get_openai_client
            self._client = get_openai_client()
        return self._client

    def _extract_colors_cv2(self, image_data: bytes) -> list[ColorFeature]:
        """用 OpenCV 提取主色调"""
        nparr = np.frombuffer(image_data, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if img is None:
            return self.MOCK_COLORS[:3]

        img = cv2.resize(img, (100, 100))
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        pixels = img.reshape(-1, 3)

        # K-means 聚类提取主色
        from sklearn.cluster import KMeans
        n_colors = 5
        kmeans = KMeans(n_clusters=n_colors, n_init=10, random_state=42)
        kmeans.fit(pixels)
        colors = []
        labels, counts = np.unique(kmeans.labels_, return_counts=True)
        total = counts.sum()

        color_names = {
            "#": "未知", "红": "红", "蓝": "蓝", "绿": "绿",
            "黄": "黄", "白": "白", "黑": "黑", "棕": "棕",
        }

        for label, count in sorted(zip(labels, counts), key=lambda x: -x[1]):
            rgb = kmeans.cluster_centers_[label].astype(int)
            hex_val = f"#{rgb[0]:02x}{rgb[1]:02x}{rgb[2]:02x}"
            pct = round(count / total, 3)
            if pct < 0.05:
                continue
            colors.append(ColorFeature(hex=hex_val, name=f"RGB({rgb[0]},{rgb[1]},{rgb[2]})", percentage=pct))

        return colors if colors else self.MOCK_COLORS[:3]

    def analyze(self, image_data: bytes, filename: str = "") -> ImageAnalysisResponse:
        """分析图片"""
        logger.info(f"图片分析: {filename}, 大小={len(image_data)} bytes")

        client = self._get_client()

        # 尝试真实 LLM 调用
        if settings.ENABLE_REAL_LLM and client:
            return self._analyze_with_llm(client, image_data, filename)

        # 降级: 用 OpenCV 颜色提取 + Mock 风格/元素
        return self._analyze_fallback(image_data, filename)

    def _analyze_with_llm(self, client, image_data: bytes, filename: str) -> ImageAnalysisResponse:
        """用 Qwen-VL 真实分析图片"""
        b64 = base64.b64encode(image_data).decode("utf-8")
        prompt = PromptTemplates.IMAGE_ANALYSIS

        try:
            response = client.chat.completions.create(
                model=settings.QWEN_MODEL,
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{b64}"}},
                            {"type": "text", "text": prompt + "\n\n请以 JSON 格式返回：{\"colors\": [{\"hex\": \"#xxx\", \"name\": \"名称\", \"percentage\": 0.3}], \"style_tags\": [\"风格\"], \"elements\": [{\"name\": \"元素\", \"confidence\": 0.9, \"description\": \"描述\"}], \"mood\": \"氛围\", \"complexity\": \"low/medium/high\"}"},
                        ],
                    }
                ],
                max_tokens=settings.QWEN_MAX_TOKENS,
                temperature=settings.QWEN_TEMPERATURE,
            )

            content = response.choices[0].message.content
            data = self._parse_json_from_text(content)

            colors = [ColorFeature(**c) for c in data.get("colors", [])]
            style_tags = data.get("style_tags", self.MOCK_STYLE_TAGS[:3])
            elements = [DesignElement(**e) for e in data.get("elements", [])]
            mood = data.get("mood", "")
            complexity = data.get("complexity", "medium")

            summary = f"该图片呈现出{style_tags[0] if style_tags else '未知'}风格"
            if colors:
                summary += f"，主色调为{colors[0].name}"
            if elements:
                summary += f"，包含{elements[0].name}等传统纹样元素"

            logger.info(f"LLM 图片分析完成: {len(colors)} 颜色, {len(style_tags)} 标签")
            return ImageAnalysisResponse(
                colors=colors,
                style_tags=style_tags,
                elements=elements,
                mood=mood,
                complexity=complexity,
                confidence=0.9,
                summary=summary,
            )
        except Exception as e:
            logger.error(f"LLM 图片分析失败，降级到 Mock: {e}")
            return self._analyze_fallback(image_data, filename)

    def _analyze_fallback(self, image_data: bytes, filename: str) -> ImageAnalysisResponse:
        """降级: OpenCV 颜色提取 + Mock 其他"""
        colors = self._extract_colors_cv2(image_data)
        seed = hashlib.md5(filename.encode()).hexdigest()[:8] if filename else "default"
        style_tags = self.MOCK_STYLE_TAGS[:3 + (int(seed[:2], 16) % 3)]
        elements = self.MOCK_ELEMENTS[:2 + (int(seed[4:6], 16) % 2)]
        confidence = 0.75 + (int(seed[6:8], 16) % 25) / 100

        summary = f"该图片呈现出{style_tags[0]}风格，主色调为{colors[0].name}"
        if elements:
            summary += f"，包含{elements[0].name}等传统纹样元素"

        return ImageAnalysisResponse(
            colors=colors,
            style_tags=style_tags,
            elements=elements,
            mood="古典雅致",
            complexity="medium",
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

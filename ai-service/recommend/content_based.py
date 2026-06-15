"""基于内容推荐 - Mock 实现
分析用户浏览历史和偏好进行推荐
"""
from loguru import logger


class ContentBasedRecommender:
    """基于内容的推荐器"""

    def __init__(self):
        logger.info("ContentBasedRecommender 初始化完成")

    def analyze_user_preference(self, user_id: str, history: list = None) -> dict:
        """分析用户偏好"""
        logger.info(f"分析用户偏好: user_id={user_id}")

        # Mock 用户偏好
        return {
            "preferred_categories": ["jewelry", "ceramic"],
            "preferred_styles": ["古典", "雅致"],
            "preferred_materials": ["银", "陶瓷"],
            "price_range": {"min": 1000, "max": 5000},
            "interaction_count": 42,
        }

    def score_candidates(
        self,
        user_preference: dict,
        candidates: list,
    ) -> list:
        """为候选项目打分"""
        scored = []
        for candidate in candidates:
            score = 0.0

            # 品类匹配
            if candidate.get("category") in user_preference.get("preferred_categories", []):
                score += 0.4

            # 风格匹配
            if candidate.get("style") in user_preference.get("preferred_styles", []):
                score += 0.3

            # 材质匹配
            candidate_materials = candidate.get("materials", [])
            preferred_materials = user_preference.get("preferred_materials", [])
            if any(m in preferred_materials for m in candidate_materials):
                score += 0.2

            # 评分加成
            score += candidate.get("rating", 0) * 0.02

            scored.append({**candidate, "content_score": round(score, 3)})

        return sorted(scored, key=lambda x: x["content_score"], reverse=True)
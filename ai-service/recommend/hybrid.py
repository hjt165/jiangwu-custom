"""混合推荐 - 真实实现
融合多种推荐策略
"""
from loguru import logger

from recommend.content_based import ContentBasedRecommender


class HybridRecommender:
    """混合推荐器"""

    WEIGHTS = {
        "style": 0.40,
        "rating": 0.30,
        "delivery": 0.20,
        "price": 0.10,
    }

    def __init__(self):
        self.content_based = ContentBasedRecommender()
        logger.info("HybridRecommender 初始化完成")

    def compute_match_score(
        self,
        user_style: str,
        user_budget: float,
        user_delivery_days: int,
        artisan: dict,
    ) -> float:
        """计算匹配度"""
        score = 0.0

        # 风格匹配 (40%)
        artisan_styles = artisan.get("styles", [])
        if user_style in artisan_styles:
            score += self.WEIGHTS["style"]
        elif any(user_style in s for s in artisan_styles):
            score += self.WEIGHTS["style"] * 0.7

        # 评分 (30%)
        rating = artisan.get("rating", 0)
        score += (rating / 5.0) * self.WEIGHTS["rating"]

        # 交付能力 (20%)
        avg_days = artisan.get("avg_delivery_days", 15)
        if avg_days <= user_delivery_days:
            score += self.WEIGHTS["delivery"]
        else:
            ratio = user_delivery_days / avg_days
            score += self.WEIGHTS["delivery"] * ratio

        # 价格匹配 (10%)
        avg_price = artisan.get("avg_price", 3000)
        if avg_price <= user_budget:
            score += self.WEIGHTS["price"]
        else:
            ratio = user_budget / avg_price
            score += self.WEIGHTS["price"] * max(0, ratio)

        return round(score, 3)

    def hybrid_rank(
        self,
        candidates: list,
        user_preference: dict = None,
    ) -> list:
        """混合排序"""
        if user_preference:
            content_scored = self.content_based.score_candidates(
                user_preference, candidates
            )
            for item in content_scored:
                hybrid_score = (
                    item.get("content_score", 0) * 0.5 +
                    item.get("match_score", 0) * 0.5
                )
                item["hybrid_score"] = round(hybrid_score, 3)
        else:
            for item in candidates:
                item["hybrid_score"] = item.get("match_score", 0)

        return sorted(candidates, key=lambda x: x.get("hybrid_score", 0), reverse=True)

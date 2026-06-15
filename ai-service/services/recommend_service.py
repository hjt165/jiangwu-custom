"""推荐服务 - 真实实现
调用 HybridRecommender + Spring Boot API
"""
import httpx
from loguru import logger

from config import settings
from schemas import (
    ArtisanRecommendRequest,
    ArtisanRecommendResponse,
    ArtisanInfo,
    SolutionRecommendRequest,
    SolutionRecommendResponse,
    SolutionItem,
)
from recommend.hybrid import HybridRecommender


class RecommendService:
    """推荐服务"""

    def __init__(self):
        self.recommender = HybridRecommender()
        logger.info("RecommendService 初始化完成")

    async def recommend_artisan(self, request: ArtisanRecommendRequest) -> ArtisanRecommendResponse:
        """推荐手作人 - 从 Spring Boot 获取真实数据 + AI 排序"""
        logger.info(f"推荐手作人: category={request.category}, style={request.style}")

        # 从后端获取手作人列表
        artisans_data = await self._fetch_artisans(request)

        if not artisans_data:
            # 降级: 使用 Mock 数据
            return self._recommend_artisan_mock(request)

        # 用 HybridRecommender 排序
        user_pref = {
            "preferred_styles": [request.style] if request.style else [],
            "preferred_categories": [request.category.value] if request.category else [],
            "price_range": {"min": request.budget_min, "max": request.budget_max},
        }

        candidates = []
        for a in artisans_data:
            candidates.append({
                "id": str(a.get("id", "")),
                "name": a.get("name", ""),
                "avatar": a.get("avatar", ""),
                "specialty": a.get("specialty", ""),
                "rating": float(a.get("rating", 0)),
                "styles": [a.get("specialty", "")],
                "avg_delivery_days": 15,
                "avg_price": 3000,
            })

        ranked = self.recommender.hybrid_rank(candidates, user_pref)

        # 用 LLM 生成匹配原因
        match_reasons = await self._generate_match_reasons(ranked[:request.top_k], request)

        artisans = []
        for i, item in enumerate(ranked[:request.top_k]):
            artisans.append(ArtisanInfo(
                id=item["id"],
                name=item["name"],
                avatar=item.get("avatar", ""),
                specialty=item.get("specialty", ""),
                rating=item["rating"],
                match_score=item.get("hybrid_score", 0),
                match_reason=match_reasons[i] if i < len(match_reasons) else f"综合评分排名第{i+1}位",
            ))

        logger.info(f"推荐 {len(artisans)} 位手作人")
        return ArtisanRecommendResponse(
            artisans=artisans,
            total=len(artisans),
            summary=f"为您推荐 {len(artisans)} 位擅长{request.category.value}的手作人",
        )

    async def recommend_solution(self, request: SolutionRecommendRequest) -> SolutionRecommendResponse:
        """推荐方案 - 基于需求 + 知识库 + LLM"""
        logger.info(f"推荐方案: budget={request.budget}, category={request.category}")

        # 如果有 LLM，用 LLM 生成方案
        if settings.ENABLE_REAL_LLM:
            try:
                return await self._generate_solution_with_llm(request)
            except Exception as e:
                logger.warning(f"LLM 方案生成失败，降级: {e}")

        # 降级: Mock 方案
        return self._recommend_solution_mock(request)

    async def _fetch_artisans(self, request: ArtisanRecommendRequest) -> list:
        """从 Spring Boot 获取手作人"""
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                url = f"{settings.SPRING_BOOT_URL}/api/artisan/list"
                resp = await client.get(url)
                resp.raise_for_status()
                data = resp.json()
                return data.get("data", [])
        except Exception as e:
            logger.warning(f"获取手作人列表失败: {e}")
            return []

    async def _generate_match_reasons(self, artisans: list, request: ArtisanRecommendRequest) -> list:
        """用 LLM 生成匹配原因"""
        if not settings.ENABLE_REAL_LLM:
            return [f"擅长{a.get('specialty', '')}，评分{a.get('rating', 0)}" for a in artisans]

        from main import get_openai_client
        client = get_openai_client()
        if not client:
            return [f"擅长{a.get('specialty', '')}，评分{a.get('rating', 0)}" for a in artisans]

        artisan_list = "\n".join([
            f"- {a['name']}: 专长{a.get('specialty', '')}, 评分{a.get('rating', 0)}"
            for a in artisans
        ])
        prompt = f"""基于用户需求和手作人特点，为每位手作人生成简短匹配原因。
用户需求: 品类={request.category.value}, 风格={request.style or '不限'}, 预算={request.budget_min}-{request.budget_max}
手作人列表:
{artisan_list}
请返回 JSON 数组: [\"原因1\", \"原因2\", ...]"""

        try:
            response = client.chat.completions.create(
                model=settings.QWEN_MODEL,
                messages=[{"role": "user", "content": prompt}],
                max_tokens=500,
                temperature=0.5,
            )
            import json
            content = response.choices[0].message.content
            start = content.find("[")
            end = content.rfind("]") + 1
            if start >= 0 and end > start:
                return json.loads(content[start:end])
        except Exception as e:
            logger.warning(f"LLM 匹配原因生成失败: {e}")

        return [f"擅长{a.get('specialty', '')}，评分{a.get('rating', 0)}" for a in artisans]

    async def _generate_solution_with_llm(self, request: SolutionRecommendRequest) -> SolutionRecommendResponse:
        """用 LLM 生成定制方案"""
        from main import get_openai_client
        client = get_openai_client()
        if not client:
            return self._recommend_solution_mock(request)

        from rag.prompt_templates import PromptTemplates
        prompt = PromptTemplates.format_template(
            "SOLUTION_GENERATION",
            requirement_sheet=f"品类: {request.category.value if request.category else '通用'}, 预算: {request.budget}, 需求: {request.description}",
            similar_cases="无",
        )

        response = client.chat.completions.create(
            model=settings.QWEN_MODEL,
            messages=[{"role": "user", "content": prompt + "\n\n请以 JSON 格式返回：[{\"title\": \"标题\", \"description\": \"描述\", \"materials\": [\"材料\"], \"techniques\": [\"技法\"], \"estimated_price\": 3000, \"estimated_days\": 15}]"}],
            max_tokens=settings.QWEN_MAX_TOKENS,
            temperature=settings.QWEN_TEMPERATURE,
        )

        import json
        content = response.choices[0].message.content
        start = content.find("[")
        end = content.rfind("]") + 1
        solutions_data = json.loads(content[start:end]) if start >= 0 else []

        solutions = []
        for i, s in enumerate(solutions_data[:request.top_k]):
            solutions.append(SolutionItem(
                id=f"solution_{i+1:03d}",
                title=s.get("title", f"方案{i+1}"),
                description=s.get("description", ""),
                materials=s.get("materials", []),
                techniques=s.get("techniques", []),
                estimated_price=float(s.get("estimated_price", request.budget)),
                estimated_days=int(s.get("estimated_days", 15)),
                match_score=0.85,
            ))

        return SolutionRecommendResponse(
            solutions=solutions,
            total=len(solutions),
            summary=f"为您生成 {len(solutions)} 个定制方案",
        )

    def _recommend_artisan_mock(self, request: ArtisanRecommendRequest) -> ArtisanRecommendResponse:
        """Mock 手作人推荐"""
        mock_artisans = [
            ArtisanInfo(id="artisan_001", name="匠心手作·李师傅", avatar="", specialty="银饰锻造", rating=4.9, match_score=0.95, match_reason="专精银饰制作，风格古朴典雅"),
            ArtisanInfo(id="artisan_002", name="竹韵工坊·王师傅", avatar="", specialty="竹编工艺", rating=4.8, match_score=0.88, match_reason="竹编技艺精湛，擅长传统纹样"),
            ArtisanInfo(id="artisan_003", name="陶语轩·张师傅", avatar="", specialty="陶瓷制作", rating=4.7, match_score=0.82, match_reason="青瓷工艺传承人，釉色温润"),
            ArtisanInfo(id="artisan_004", name="木雕坊·陈师傅", avatar="", specialty="木雕艺术", rating=4.6, match_score=0.78, match_reason="东阳木雕传承人，刀工细腻"),
            ArtisanInfo(id="artisan_005", name="皮艺堂·刘师傅", avatar="", specialty="皮具手作", rating=4.5, match_score=0.75, match_reason="植鞣皮手工皮具，做工精细"),
        ]
        artisans = mock_artisans[:request.top_k]
        return ArtisanRecommendResponse(
            artisans=artisans,
            total=len(artisans),
            summary=f"为您推荐 {len(artisans)} 位擅长{request.category.value}的手作人",
        )

    def _recommend_solution_mock(self, request: SolutionRecommendRequest) -> SolutionRecommendResponse:
        """Mock 方案推荐"""
        mock_solutions = [
            SolutionItem(id="solution_001", title="银饰古法锻造方案", description="采用传统古法银饰锻造工艺", materials=["925纯银", "天然玛瑙"], techniques=["古法锻造", "手工锤纹"], estimated_price=3800, estimated_days=15, match_score=0.92),
            SolutionItem(id="solution_002", title="银饰现代简约方案", description="现代简约风格银饰", materials=["925纯银", "锆石"], techniques=["精密铸造", "抛光"], estimated_price=2800, estimated_days=10, match_score=0.85),
            SolutionItem(id="solution_003", title="竹编茶具收纳方案", description="手工竹编茶具收纳盒", materials=["三年以上毛竹", "天然大漆"], techniques=["竹编", "榫卯结构"], estimated_price=1500, estimated_days=20, match_score=0.78),
        ]
        solutions = mock_solutions[:request.top_k]
        return SolutionRecommendResponse(
            solutions=solutions,
            total=len(solutions),
            summary=f"为您生成 {len(solutions)} 个定制方案",
        )

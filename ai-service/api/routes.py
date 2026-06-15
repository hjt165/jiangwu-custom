"""API 路由定义"""
from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import Optional

from schemas import (
    ImageAnalysisResponse,
    TextAnalysisResponse,
    MultimodalAnalysisResponse,
    ArtisanRecommendRequest,
    ArtisanRecommendResponse,
    SolutionRecommendRequest,
    SolutionRecommendResponse,
    SimilarCaseResponse,
    HealthResponse,
)
from services.analysis_service import AnalysisService
from services.recommend_service import RecommendService
from rag.retriever import Retriever
from config import settings

router = APIRouter()
analysis_service = AnalysisService()
recommend_service = RecommendService()
retriever = Retriever()


@router.get("/health", response_model=HealthResponse)
async def health_check():
    """健康检查"""
    services_status = {
        "analysis": "real" if settings.ENABLE_REAL_LLM else "mock",
        "recommend": "real" if settings.ENABLE_REAL_LLM else "mock",
        "rag": "mock",
    }

    # 检查 Milvus
    try:
        from main import get_milvus_client
        milvus = get_milvus_client()
        if milvus:
            services_status["milvus"] = "connected"
        else:
            services_status["milvus"] = "disconnected"
    except Exception:
        services_status["milvus"] = "error"

    # 检查 Redis
    try:
        from main import get_redis_client
        redis_client = get_redis_client()
        if redis_client:
            redis_client.ping()
            services_status["redis"] = "connected"
        else:
            services_status["redis"] = "disconnected"
    except Exception:
        services_status["redis"] = "error"

    return HealthResponse(
        status="healthy",
        version=settings.APP_VERSION,
        services=services_status,
    )


@router.post("/analyze/image", response_model=ImageAnalysisResponse)
async def analyze_image(
    file: UploadFile = File(...),
    description: Optional[str] = Form(None),
):
    """图片分析 - 提取颜色、风格、设计元素"""
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="仅支持图片文件")

    image_data = await file.read()
    result = analysis_service.analyze_image(
        image_data=image_data,
        filename=file.filename,
        description=description,
    )
    return result


@router.post("/analyze/text", response_model=TextAnalysisResponse)
async def analyze_text(
    text: str = Form(...),
    category: Optional[str] = Form(None),
):
    """文字分析 - 意图识别、关键词提取、需求结构化"""
    if not text.strip():
        raise HTTPException(status_code=400, detail="文本不能为空")

    result = analysis_service.analyze_text(
        text=text,
        category=category,
    )
    return result


@router.post("/analyze/multimodal", response_model=MultimodalAnalysisResponse)
async def analyze_multimodal(
    file: Optional[UploadFile] = File(None),
    text: Optional[str] = Form(None),
    category: Optional[str] = Form(None),
):
    """多模态联合分析 - 图片+文字融合分析"""
    image_data = None
    if file is not None:
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="仅支持图片文件")
        image_data = await file.read()

    if image_data is None and not text:
        raise HTTPException(status_code=400, detail="请提供图片或文字描述")

    result = analysis_service.analyze_multimodal(
        image_data=image_data,
        text=text,
        category=category,
    )
    return result


@router.post("/recommend/artisan", response_model=ArtisanRecommendResponse)
async def recommend_artisan(request: ArtisanRecommendRequest):
    """手作人推荐 - 基于风格、评分、交付、价格加权推荐"""
    result = await recommend_service.recommend_artisan(request)
    return result


@router.post("/recommend/solution", response_model=SolutionRecommendResponse)
async def recommend_solution(request: SolutionRecommendRequest):
    """方案推荐 - 基于需求推荐材料、技法、手作人组合"""
    result = await recommend_service.recommend_solution(request)
    return result


@router.get("/rag/similar/{case_id}", response_model=SimilarCaseResponse)
async def get_similar_cases(
    case_id: str,
    top_k: int = 5,
):
    """相似案例检索 - 基于向量相似度检索历史案例"""
    result = retriever.find_similar(case_id=case_id, top_k=top_k)
    return result

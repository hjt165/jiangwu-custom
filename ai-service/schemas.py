"""Pydantic 数据模型 - 请求/响应"""
from pydantic import BaseModel, Field
from typing import Optional
from enum import Enum


# ==================== 枚举类型 ====================

class ProductCategory(str, Enum):
    jewelry = "jewelry"
    leather = "leather"
    ceramic = "ceramic"
    woodwork = "woodwork"
    painting = "painting"
    other = "other"


class AnalysisConfidence(str, Enum):
    high = "high"
    medium = "medium"
    low = "low"


# ==================== 图片分析 ====================

class ColorFeature(BaseModel):
    """颜色特征"""
    hex: str = Field(..., description="颜色十六进制值")
    name: str = Field(..., description="颜色名称")
    percentage: float = Field(..., description="占比百分比")


class DesignElement(BaseModel):
    """设计元素"""
    name: str = Field(..., description="元素名称")
    confidence: float = Field(..., description="置信度 0-1")
    description: str = Field("", description="元素描述")


class ImageAnalysisResponse(BaseModel):
    """图片分析响应"""
    colors: list[ColorFeature] = Field(default_factory=list, description="颜色特征")
    style_tags: list[str] = Field(default_factory=list, description="风格标签")
    elements: list[DesignElement] = Field(default_factory=list, description="设计元素")
    mood: str = Field("", description="氛围/情绪")
    complexity: str = Field("medium", description="复杂度 low/medium/high")
    confidence: float = Field(0.85, description="整体置信度")
    summary: str = Field("", description="分析摘要")


# ==================== 文字分析 ====================

class IntentResult(BaseModel):
    """意图识别结果"""
    intent: str = Field(..., description="意图类型")
    confidence: float = Field(..., description="置信度")
    parameters: dict = Field(default_factory=dict, description="提取的参数")


class TextAnalysisResponse(BaseModel):
    """文字分析响应"""
    intents: list[IntentResult] = Field(default_factory=list, description="识别到的意图")
    keywords: list[str] = Field(default_factory=list, description="关键词")
    category: str = Field("", description="推荐品类")
    requirements: dict = Field(default_factory=dict, description="结构化需求")
    summary: str = Field("", description="分析摘要")
    confidence: float = Field(0.85, description="整体置信度")


# ==================== 多模态分析 ====================

class RequirementSheet(BaseModel):
    """定制需求表"""
    title: str = Field("", description="需求标题")
    category: str = Field("", description="品类")
    description: str = Field("", description="详细描述")
    materials: list[str] = Field(default_factory=list, description="推荐材料")
    techniques: list[str] = Field(default_factory=list, description="推荐技法")
    style: str = Field("", description="风格")
    budget_range: str = Field("", description="预算范围")
    reference_elements: list[str] = Field(default_factory=list, description="参考元素")


class MultimodalAnalysisResponse(BaseModel):
    """多模态联合分析响应"""
    requirement_sheet: RequirementSheet = Field(default_factory=RequirementSheet, description="需求表")
    image_analysis: Optional[ImageAnalysisResponse] = Field(None, description="图片分析结果")
    text_analysis: Optional[TextAnalysisResponse] = Field(None, description="文字分析结果")
    confidence: float = Field(0.85, description="整体置信度")
    summary: str = Field("", description="综合分析摘要")


# ==================== 推荐 ====================

class ArtisanRecommendRequest(BaseModel):
    """手作人推荐请求"""
    category: ProductCategory = Field(..., description="品类")
    style: str = Field("", description="风格偏好")
    budget_min: float = Field(0, description="最低预算")
    budget_max: float = Field(99999, description="最高预算")
    delivery_days: int = Field(30, description="期望交付天数")
    top_k: int = Field(10, description="返回数量")


class ArtisanInfo(BaseModel):
    """手作人信息"""
    id: str = Field(..., description="手作人ID")
    name: str = Field(..., description="手作人名称")
    avatar: str = Field("", description="头像URL")
    specialty: str = Field("", description="专长")
    rating: float = Field(0, description="评分")
    match_score: float = Field(0, description="匹配度 0-1")
    match_reason: str = Field("", description="匹配原因")


class ArtisanRecommendResponse(BaseModel):
    """手作人推荐响应"""
    artisans: list[ArtisanInfo] = Field(default_factory=list, description="推荐手作人列表")
    total: int = Field(0, description="总数")
    summary: str = Field("", description="推荐摘要")


class SolutionRecommendRequest(BaseModel):
    """方案推荐请求"""
    description: str = Field("", description="需求描述")
    image_url: Optional[str] = Field(None, description="参考图片URL")
    category: Optional[ProductCategory] = Field(None, description="品类")
    budget: float = Field(5000, description="预算")
    top_k: int = Field(5, description="返回数量")


class SolutionItem(BaseModel):
    """推荐方案项"""
    id: str = Field(..., description="方案ID")
    title: str = Field(..., description="方案标题")
    description: str = Field("", description="方案描述")
    materials: list[str] = Field(default_factory=list, description="材料")
    techniques: list[str] = Field(default_factory=list, description="技法")
    estimated_price: float = Field(0, description="预估价格")
    estimated_days: int = Field(0, description="预估天数")
    match_score: float = Field(0, description="匹配度")
    artisan_id: str = Field("", description="推荐手作人ID")
    artisan_name: str = Field("", description="手作人名称")


class SolutionRecommendResponse(BaseModel):
    """方案推荐响应"""
    solutions: list[SolutionItem] = Field(default_factory=list, description="推荐方案列表")
    total: int = Field(0, description="总数")
    summary: str = Field("", description="推荐摘要")


# ==================== RAG ====================

class SimilarCase(BaseModel):
    """相似案例"""
    id: str = Field(..., description="案例ID")
    title: str = Field(..., description="案例标题")
    description: str = Field("", description="案例描述")
    image_url: str = Field("", description="案例图片")
    similarity: float = Field(0, description="相似度 0-1")
    category: str = Field("", description="品类")
    price: float = Field(0, description="成交价格")


class SimilarCaseResponse(BaseModel):
    """相似案例检索响应"""
    cases: list[SimilarCase] = Field(default_factory=list, description="相似案例列表")
    total: int = Field(0, description="总数")
    query_time_ms: float = Field(0, description="查询耗时(毫秒)")


# ==================== 健康检查 ====================

class HealthResponse(BaseModel):
    """健康检查响应"""
    status: str = Field("healthy", description="服务状态")
    version: str = Field("1.0.0", description="版本号")
    services: dict = Field(default_factory=dict, description="依赖服务状态")
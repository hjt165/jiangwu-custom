"""AI 服务 Schema 单元测试"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from schemas import (
    ProductCategory, AnalysisConfidence,
    ColorFeature, DesignElement, ImageAnalysisResponse,
    IntentResult, TextAnalysisResponse,
    RequirementSheet, MultimodalAnalysisResponse,
    ArtisanRecommendRequest, ArtisanInfo, ArtisanRecommendResponse,
    SolutionRecommendRequest, SolutionItem, SolutionRecommendResponse,
    SimilarCase, SimilarCaseResponse,
    HealthResponse,
)


def test_product_category_enum():
    assert ProductCategory.jewelry.value == "jewelry"
    assert ProductCategory.leather.value == "leather"
    assert ProductCategory.ceramic.value == "ceramic"
    assert ProductCategory.woodwork.value == "woodwork"
    assert ProductCategory.painting.value == "painting"
    assert ProductCategory.other.value == "other"


def test_analysis_confidence_enum():
    assert AnalysisConfidence.high.value == "high"
    assert AnalysisConfidence.medium.value == "medium"
    assert AnalysisConfidence.low.value == "low"


def test_color_feature():
    c = ColorFeature(hex="#FF0000", name="红色", percentage=30.5)
    assert c.hex == "#FF0000"
    assert c.name == "红色"
    assert c.percentage == 30.5


def test_design_element():
    e = DesignElement(name="花纹", confidence=0.92, description="传统云纹")
    assert e.name == "花纹"
    assert e.confidence == 0.92


def test_image_analysis_response_defaults():
    r = ImageAnalysisResponse()
    assert r.colors == []
    assert r.style_tags == []
    assert r.complexity == "medium"
    assert r.confidence == 0.85


def test_image_analysis_response_with_data():
    r = ImageAnalysisResponse(
        colors=[ColorFeature(hex="#000", name="黑", percentage=50)],
        style_tags=["复古", "中式"],
        mood="典雅",
        summary="一件复古中式作品"
    )
    assert len(r.colors) == 1
    assert len(r.style_tags) == 2
    assert r.mood == "典雅"


def test_intent_result():
    i = IntentResult(intent="定制", confidence=0.95, parameters={"category": "jewelry"})
    assert i.intent == "定制"
    assert i.parameters["category"] == "jewelry"


def test_text_analysis_response_defaults():
    r = TextAnalysisResponse()
    assert r.intents == []
    assert r.keywords == []
    assert r.confidence == 0.85


def test_requirement_sheet():
    rs = RequirementSheet(
        title="翡翠手镯定制",
        category="jewelry",
        materials=["翡翠", "银"],
        techniques=["雕刻"],
        budget_range="3000-5000"
    )
    assert rs.title == "翡翠手镯定制"
    assert len(rs.materials) == 2
    assert rs.budget_range == "3000-5000"


def test_multimodal_analysis_response():
    r = MultimodalAnalysisResponse(
        requirement_sheet=RequirementSheet(title="测试"),
        confidence=0.9,
        summary="综合分析"
    )
    assert r.confidence == 0.9
    assert r.image_analysis is None
    assert r.text_analysis is None


def test_artisan_recommend_request():
    req = ArtisanRecommendRequest(
        category=ProductCategory.ceramic,
        style="简约",
        budget_min=1000,
        budget_max=5000
    )
    assert req.category == ProductCategory.ceramic
    assert req.top_k == 10  # default


def test_artisan_info():
    a = ArtisanInfo(
        id="1",
        name="匠心手作",
        rating=4.8,
        match_score=0.95,
        match_reason="擅长陶瓷"
    )
    assert a.id == "1"
    assert a.match_score == 0.95


def test_artisan_recommend_response():
    r = ArtisanRecommendResponse(
        artisans=[
            ArtisanInfo(id="1", name="A"),
            ArtisanInfo(id="2", name="B"),
        ],
        total=2,
        summary="推荐2位手作人"
    )
    assert r.total == 2
    assert len(r.artisans) == 2


def test_solution_recommend_request():
    req = SolutionRecommendRequest(
        description="定制一个翡翠手镯",
        budget=5000
    )
    assert req.description == "定制一个翡翠手镯"
    assert req.top_k == 5  # default


def test_solution_item():
    s = SolutionItem(
        id="s1",
        title="方案一",
        estimated_price=3500,
        estimated_days=14,
        match_score=0.88
    )
    assert s.id == "s1"
    assert s.estimated_price == 3500


def test_similar_case():
    c = SimilarCase(
        id="c1",
        title="翡翠吊坠",
        similarity=0.92,
        price=2800
    )
    assert c.similarity == 0.92
    assert c.price == 2800


def test_similar_case_response():
    r = SimilarCaseResponse(cases=[], total=0, query_time_ms=12.5)
    assert r.query_time_ms == 12.5
    assert r.cases == []


def test_health_response():
    h = HealthResponse()
    assert h.status == "healthy"
    assert h.version == "1.0.0"
    assert h.services == {}


def test_health_response_with_services():
    h = HealthResponse(
        status="healthy",
        services={"milvus": "connected", "redis": "connected"}
    )
    assert h.services["milvus"] == "connected"

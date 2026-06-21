"""多模态融合器单元测试"""
import pytest
from unittest.mock import patch, MagicMock
from schemas import ImageAnalysisResponse, TextAnalysisResponse, DesignElement
from multimodal.fusion import MultimodalFusion


@pytest.fixture
def fusion():
    return MultimodalFusion()


@pytest.fixture
def image_result():
    return ImageAnalysisResponse(
        style_tags=["古典", "雅致"],
        elements=[DesignElement(name="龙纹", confidence=0.9), DesignElement(name="祥云", confidence=0.8)],
        mood="庄重",
        summary="图片展示了一件古典风格的龙纹饰品",
        confidence=0.85,
    )


@pytest.fixture
def text_result():
    return TextAnalysisResponse(
        category="jewelry",
        keywords=["银饰", "龙纹"],
        requirements={"style": "古典", "budget_range": "3000-5000"},
        intent="定制",
        summary="用户想要定制一件古典风格的银饰",
        confidence=0.9,
    )


class TestMultimodalFusionFallback:
    def test_fallback_with_category_override(self, fusion):
        result = fusion._fuse_fallback(category="ceramic")
        assert result.requirement_sheet.category == "ceramic"
        assert "陶瓷" in result.requirement_sheet.materials[0] or "高岭土" in result.requirement_sheet.materials[0]

    def test_fallback_default_category_is_jewelry(self, fusion):
        result = fusion._fuse_fallback()
        assert result.requirement_sheet.category == "jewelry"

    def test_fallback_with_text_result_uses_text_category(self, fusion, text_result):
        result = fusion._fuse_fallback(text_result=text_result)
        assert result.requirement_sheet.category == "jewelry"

    def test_fallback_with_image_result_uses_image_style(self, fusion, image_result):
        result = fusion._fuse_fallback(image_result=image_result)
        assert result.requirement_sheet.style == "古典"

    def test_fallback_with_both_results_averages_confidence(self, fusion, image_result, text_result):
        result = fusion._fuse_fallback(image_result=image_result, text_result=text_result)
        expected_confidence = (0.85 + 0.9) / 2
        assert result.confidence == round(expected_confidence, 2)

    def test_fallback_image_only_uses_image_confidence(self, fusion, image_result):
        result = fusion._fuse_fallback(image_result=image_result)
        assert result.confidence == 0.85

    def test_fallback_text_only_uses_text_confidence(self, fusion, text_result):
        result = fusion._fuse_fallback(text_result=text_result)
        assert result.confidence == 0.9

    def test_fallback_no_results_default_confidence(self, fusion):
        result = fusion._fuse_fallback()
        assert result.confidence == 0.85

    def test_fallback_extracts_reference_elements(self, fusion, image_result):
        result = fusion._fuse_fallback(image_result=image_result)
        assert "龙纹" in result.requirement_sheet.reference_elements
        assert "祥云" in result.requirement_sheet.reference_elements

    def test_fallback_no_image_no_reference_elements(self, fusion):
        result = fusion._fuse_fallback()
        assert result.requirement_sheet.reference_elements == []

    def test_fallback_materials_limited_to_3(self, fusion):
        result = fusion._fuse_fallback(category="jewelry")
        assert len(result.requirement_sheet.materials) <= 3

    def test_fallback_techniques_limited_to_3(self, fusion):
        result = fusion._fuse_fallback(category="jewelry")
        assert len(result.requirement_sheet.techniques) <= 3

    def test_fallback_generates_title(self, fusion):
        result = fusion._fuse_fallback(category="leather")
        assert "定制" in result.requirement_sheet.title
        assert "leather" in result.requirement_sheet.title

    def test_fallback_generates_summary(self, fusion):
        result = fusion._fuse_fallback()
        assert result.summary != ""
        assert "已生成" in result.summary

    def test_fallback_text_provides_description(self, fusion, text_result):
        result = fusion._fuse_fallback(text_result=text_result)
        assert "定制" in result.requirement_sheet.description

    def test_fallback_woodwork_materials(self, fusion):
        result = fusion._fuse_fallback(category="woodwork")
        assert any("紫檀" in m or "花梨" in m or "楠木" in m for m in result.requirement_sheet.materials)

    def test_fallback_leather_materials(self, fusion):
        result = fusion._fuse_fallback(category="leather")
        assert any("皮" in m for m in result.requirement_sheet.materials)

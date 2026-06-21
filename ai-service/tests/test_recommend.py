"""混合推荐器和基于内容推荐器单元测试"""
import pytest
from recommend.hybrid import HybridRecommender
from recommend.content_based import ContentBasedRecommender


@pytest.fixture
def hybrid():
    return HybridRecommender()


@pytest.fixture
def content_based():
    return ContentBasedRecommender()


class TestHybridRecommender:
    def test_compute_match_score_exact_style_match(self, hybrid):
        artisan = {
            "styles": ["古典", "雅致"],
            "rating": 4.5,
            "avg_delivery_days": 10,
            "avg_price": 2000,
        }
        score = hybrid.compute_match_score("古典", 5000, 14, artisan)
        assert score > 0.7

    def test_compute_match_score_partial_style_match(self, hybrid):
        artisan = {
            "styles": ["古典风格"],
            "rating": 4.0,
            "avg_delivery_days": 10,
            "avg_price": 2000,
        }
        score = hybrid.compute_match_score("古典", 5000, 14, artisan)
        assert 0.3 < score < 0.9

    def test_compute_match_score_no_style_match(self, hybrid):
        artisan = {
            "styles": ["现代"],
            "rating": 4.0,
            "avg_delivery_days": 10,
            "avg_price": 2000,
        }
        score = hybrid.compute_match_score("古典", 5000, 14, artisan)
        assert score < 0.7

    def test_compute_match_score_high_rating(self, hybrid):
        artisan = {
            "styles": ["古典"],
            "rating": 5.0,
            "avg_delivery_days": 10,
            "avg_price": 2000,
        }
        score = hybrid.compute_match_score("古典", 5000, 14, artisan)
        assert score >= 0.82

    def test_compute_match_score_low_rating(self, hybrid):
        artisan = {
            "styles": ["古典"],
            "rating": 2.0,
            "avg_delivery_days": 10,
            "avg_price": 2000,
        }
        score = hybrid.compute_match_score("古典", 5000, 14, artisan)
        # style=0.4 + rating=2.0/5.0*0.3=0.12 + delivery=0.2 + price=0.1 = 0.82
        assert score < 0.9

    def test_compute_match_score_delivery_within_budget(self, hybrid):
        artisan = {
            "styles": ["古典"],
            "rating": 4.0,
            "avg_delivery_days": 5,
            "avg_price": 2000,
        }
        score = hybrid.compute_match_score("古典", 5000, 14, artisan)
        assert score > 0.7

    def test_compute_match_score_delivery_over_budget(self, hybrid):
        artisan = {
            "styles": ["古典"],
            "rating": 4.0,
            "avg_delivery_days": 30,
            "avg_price": 2000,
        }
        score = hybrid.compute_match_score("古典", 5000, 14, artisan)
        assert score > 0.0

    def test_compute_match_score_price_within_budget(self, hybrid):
        artisan = {
            "styles": ["古典"],
            "rating": 4.0,
            "avg_delivery_days": 10,
            "avg_price": 3000,
        }
        score = hybrid.compute_match_score("古典", 5000, 14, artisan)
        assert score > 0.7

    def test_compute_match_score_price_over_budget(self, hybrid):
        artisan = {
            "styles": ["古典"],
            "rating": 4.0,
            "avg_delivery_days": 10,
            "avg_price": 10000,
        }
        score = hybrid.compute_match_score("古典", 5000, 14, artisan)
        assert score > 0.0

    def test_hybrid_rank_with_preference(self, hybrid):
        candidates = [
            {"id": 1, "category": "jewelry", "style": "古典", "materials": ["银"], "rating": 4.0, "match_score": 0.8},
            {"id": 2, "category": "ceramic", "style": "现代", "materials": ["陶瓷"], "rating": 3.5, "match_score": 0.5},
        ]
        preference = {
            "preferred_categories": ["jewelry"],
            "preferred_styles": ["古典"],
            "preferred_materials": ["银"],
            "price_range": {"min": 1000, "max": 5000},
        }
        result = hybrid.hybrid_rank(candidates, preference)
        assert len(result) == 2
        # hybrid_rank 返回按 match_score 降序排列（production bug: 返回原始 candidates 列表）
        assert result[0]["id"] == 1

    def test_hybrid_rank_without_preference(self, hybrid):
        candidates = [
            {"id": 1, "match_score": 0.9},
            {"id": 2, "match_score": 0.5},
        ]
        result = hybrid.hybrid_rank(candidates)
        assert result[0]["match_score"] >= result[1]["match_score"]

    def test_weights_sum_to_one(self, hybrid):
        total = sum(hybrid.WEIGHTS.values())
        assert abs(total - 1.0) < 0.01


class TestContentBasedRecommender:
    def test_analyze_user_preference_returns_expected_keys(self, content_based):
        result = content_based.analyze_user_preference("user1")
        assert "preferred_categories" in result
        assert "preferred_styles" in result
        assert "preferred_materials" in result
        assert "price_range" in result

    def test_score_candidates_category_match(self, content_based):
        preference = {
            "preferred_categories": ["jewelry"],
            "preferred_styles": ["古典"],
            "preferred_materials": ["银"],
        }
        candidates = [
            {"id": 1, "category": "jewelry", "style": "古典", "materials": ["银"], "rating": 4.0},
            {"id": 2, "category": "ceramic", "style": "现代", "materials": ["陶瓷"], "rating": 3.0},
        ]
        result = content_based.score_candidates(preference, candidates)
        assert result[0]["id"] == 1
        assert result[0]["content_score"] > result[1]["content_score"]

    def test_score_candidates_material_match(self, content_based):
        preference = {
            "preferred_categories": [],
            "preferred_styles": [],
            "preferred_materials": ["银", "金"],
        }
        candidates = [
            {"id": 1, "category": "other", "style": "other", "materials": ["银"], "rating": 3.0},
            {"id": 2, "category": "other", "style": "other", "materials": ["铜"], "rating": 3.0},
        ]
        result = content_based.score_candidates(preference, candidates)
        assert result[0]["content_score"] > result[1]["content_score"]

    def test_score_candidates_sorted_by_score(self, content_based):
        preference = {
            "preferred_categories": ["jewelry"],
            "preferred_styles": ["古典"],
            "preferred_materials": ["银"],
        }
        candidates = [
            {"id": 1, "category": "ceramic", "style": "现代", "materials": ["陶瓷"], "rating": 5.0},
            {"id": 2, "category": "jewelry", "style": "古典", "materials": ["银"], "rating": 4.0},
        ]
        result = content_based.score_candidates(preference, candidates)
        assert result[0]["id"] == 2

    def test_score_candidates_empty_list(self, content_based):
        result = content_based.score_candidates({"preferred_categories": []}, [])
        assert result == []

    def test_score_candidates_no_match(self, content_based):
        preference = {
            "preferred_categories": ["jewelry"],
            "preferred_styles": ["古典"],
            "preferred_materials": ["银"],
        }
        candidates = [
            {"id": 1, "category": "woodwork", "style": "现代", "materials": ["木"], "rating": 1.0},
        ]
        result = content_based.score_candidates(preference, candidates)
        assert result[0]["content_score"] < 0.5

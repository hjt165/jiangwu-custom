package com.jiangwu.service;

import com.jiangwu.dto.response.ArtisanResponse;
import com.jiangwu.entity.Artisan;
import com.jiangwu.entity.Product;
import com.jiangwu.enums.ArtisanStatus;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.repository.ArtisanRepository;
import com.jiangwu.repository.ProductRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ArtisanServiceTest {

    @Mock private ArtisanRepository artisanRepository;
    @Mock private ProductRepository productRepository;
    @InjectMocks private ArtisanService artisanService;

    private Artisan testArtisan;
    private Product testProduct;

    @BeforeEach
    void setUp() {
        testArtisan = new Artisan();
        testArtisan.setId(1L);
        testArtisan.setUserId(100L);
        testArtisan.setName("匠心手作·李师傅");
        testArtisan.setSpecialty("银饰锻造");
        testArtisan.setStatus(ArtisanStatus.VERIFIED);
        testArtisan.setRating(new BigDecimal("4.80"));
        testArtisan.setOrderCount(10);
        testArtisan.setFanCount(50);

        testProduct = new Product();
        testProduct.setId(1L);
        testProduct.setArtisanId(1L);
        testProduct.setTitle("古法银镯");
        testProduct.setPrice(new BigDecimal("3800.00"));
        testProduct.setIsAvailable(true);
    }

    // ==================== 列表查询 ====================

    @Test
    void getArtisanList_ReturnsVerifiedArtisans() {
        when(artisanRepository.findByStatus(ArtisanStatus.VERIFIED)).thenReturn(List.of(testArtisan));

        List<ArtisanResponse> result = artisanService.getArtisanList();

        assertEquals(1, result.size());
        assertEquals("匠心手作·李师傅", result.get(0).getName());
    }

    @Test
    void getArtisanList_EmptyWhenNoVerified() {
        when(artisanRepository.findByStatus(ArtisanStatus.VERIFIED)).thenReturn(List.of());

        List<ArtisanResponse> result = artisanService.getArtisanList();

        assertTrue(result.isEmpty());
    }

    // ==================== 详情查询 ====================

    @Test
    void getArtisanDetail_Success() {
        when(artisanRepository.findById(1L)).thenReturn(testArtisan);

        ArtisanResponse result = artisanService.getArtisanDetail(1L);

        assertEquals("匠心手作·李师傅", result.getName());
        assertEquals("银饰锻造", result.getSpecialty());
    }

    @Test
    void getArtisanDetail_NotFound_ThrowsException() {
        when(artisanRepository.findById(999L)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> artisanService.getArtisanDetail(999L));
    }

    @Test
    void getArtisanByUserId_Found() {
        when(artisanRepository.findByUserId(100L)).thenReturn(testArtisan);

        ArtisanResponse result = artisanService.getArtisanByUserId(100L);

        assertNotNull(result);
        assertEquals("匠心手作·李师傅", result.getName());
    }

    @Test
    void getArtisanByUserId_NotFound_ReturnsNull() {
        when(artisanRepository.findByUserId(999L)).thenReturn(null);

        ArtisanResponse result = artisanService.getArtisanByUserId(999L);

        assertNull(result);
    }

    // ==================== 申请成为手作人 ====================

    @Test
    void applyArtisan_Success() {
        when(artisanRepository.findByUserId(200L)).thenReturn(null);
        doReturn(1).when(artisanRepository).insert(any(Artisan.class));

        assertDoesNotThrow(() ->
                artisanService.applyArtisan(200L, "新匠人", "热爱手工", "木雕", 5, "杭州"));

        verify(artisanRepository).insert(any(Artisan.class));
    }

    @Test
    void applyArtisan_AlreadyApplied_ThrowsException() {
        when(artisanRepository.findByUserId(100L)).thenReturn(testArtisan);

        assertThrows(BusinessException.class,
                () -> artisanService.applyArtisan(100L, "重复申请", "", "", null, ""));
    }

    // ==================== 搜索 ====================

    @Test
    void searchArtisans_ReturnsResults() {
        when(artisanRepository.search("银饰")).thenReturn(List.of(testArtisan));

        List<ArtisanResponse> result = artisanService.searchArtisans("银饰");

        assertEquals(1, result.size());
    }

    @Test
    void searchArtisans_EmptyForNoMatch() {
        when(artisanRepository.search("不存在")).thenReturn(List.of());

        List<ArtisanResponse> result = artisanService.searchArtisans("不存在");

        assertTrue(result.isEmpty());
    }

    // ==================== 评分更新 ====================

    @Test
    void updateArtisanRating_Success() {
        doReturn(1).when(artisanRepository).updateRating(eq(1L), any(BigDecimal.class));

        assertDoesNotThrow(() -> artisanService.updateArtisanRating(1L, 4.9));
        verify(artisanRepository).updateRating(eq(1L), any(BigDecimal.class));
    }

    // ==================== 手作人作品 ====================

    @Test
    void findArtisanProducts_ReturnsProductList() {
        when(productRepository.findByArtisanId(1L)).thenReturn(List.of(testProduct));

        List<Map<String, Object>> result = artisanService.findArtisanProducts(1L);

        assertEquals(1, result.size());
        assertEquals("古法银镯", result.get(0).get("title"));
    }

    @Test
    void findArtisanProducts_EmptyForNewArtisan() {
        when(productRepository.findByArtisanId(999L)).thenReturn(List.of());

        List<Map<String, Object>> result = artisanService.findArtisanProducts(999L);

        assertTrue(result.isEmpty());
    }

    // ==================== findArtisanById ====================

    @Test
    void findArtisanById_Success() {
        when(artisanRepository.findById(1L)).thenReturn(testArtisan);

        ArtisanResponse result = artisanService.findArtisanById(1L);

        assertNotNull(result);
        assertEquals("匠心手作·李师傅", result.getName());
    }

    @Test
    void findArtisanById_NotFound_ThrowsException() {
        when(artisanRepository.findById(999L)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> artisanService.findArtisanById(999L));
    }

    // ==================== findAllArtisans ====================

    @Test
    void findAllArtisans_ReturnsAll() {
        when(artisanRepository.selectList(null)).thenReturn(List.of(testArtisan));

        List<ArtisanResponse> result = artisanService.findAllArtisans();

        assertEquals(1, result.size());
    }
}

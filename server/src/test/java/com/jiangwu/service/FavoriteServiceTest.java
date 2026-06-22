package com.jiangwu.service;

import com.jiangwu.entity.Product;
import com.jiangwu.entity.UserFavorite;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.repository.ProductImageRepository;
import com.jiangwu.repository.ProductRepository;
import com.jiangwu.repository.UserFavoriteRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FavoriteServiceTest {

    @Mock private UserFavoriteRepository favoriteRepository;
    @Mock private ProductRepository productRepository;
    @Mock private ProductImageRepository productImageRepository;
    @InjectMocks private FavoriteService favoriteService;

    private Product testProduct;

    @BeforeEach
    void setUp() {
        testProduct = new Product();
        testProduct.setId(1L);
        testProduct.setTitle("银饰手镯");
        testProduct.setLikeCount(5);
    }

    @Test
    void addFavorite_Success() {
        when(productRepository.findById(1L)).thenReturn(testProduct);
        when(favoriteRepository.findByUserAndProduct(1L, 1L)).thenReturn(null);
        doReturn(1).when(favoriteRepository).insert(any(UserFavorite.class));
        doReturn(1).when(productRepository).updateLikeCount(1L, 1);

        assertDoesNotThrow(() -> favoriteService.addFavorite(1L, 1L));
        verify(productRepository).updateLikeCount(1L, 1);
    }

    @Test
    void addFavorite_ProductNotFound_ThrowsException() {
        when(productRepository.findById(999L)).thenReturn(null);
        assertThrows(BusinessException.class, () -> favoriteService.addFavorite(1L, 999L));
    }

    @Test
    void addFavorite_AlreadyFavorited_ThrowsException() {
        when(productRepository.findById(1L)).thenReturn(testProduct);
        when(favoriteRepository.findByUserAndProduct(1L, 1L)).thenReturn(new UserFavorite());
        assertThrows(BusinessException.class, () -> favoriteService.addFavorite(1L, 1L));
    }

    @Test
    void removeFavorite_Success() {
        when(favoriteRepository.findByUserAndProduct(1L, 1L)).thenReturn(new UserFavorite());
        when(favoriteRepository.deleteByUserAndProduct(1L, 1L)).thenReturn(1);
        doReturn(1).when(productRepository).updateLikeCount(1L, -1);

        assertDoesNotThrow(() -> favoriteService.removeFavorite(1L, 1L));
        verify(productRepository).updateLikeCount(1L, -1);
    }

    @Test
    void removeFavorite_NotFound_ThrowsException() {
        when(favoriteRepository.findByUserAndProduct(1L, 1L)).thenReturn(null);
        assertThrows(BusinessException.class, () -> favoriteService.removeFavorite(1L, 1L));
    }

    @Test
    void toggleFavorite_AddsWhenNotFavorited() {
        when(favoriteRepository.findByUserAndProduct(1L, 1L)).thenReturn(null);
        when(productRepository.findById(1L)).thenReturn(testProduct);
        doReturn(1).when(favoriteRepository).insert(any(UserFavorite.class));
        doReturn(1).when(productRepository).updateLikeCount(1L, 1);

        boolean result = favoriteService.toggleFavorite(1L, 1L);
        assertTrue(result);
    }

    @Test
    void toggleFavorite_RemovesWhenFavorited() {
        when(favoriteRepository.findByUserAndProduct(1L, 1L)).thenReturn(new UserFavorite());
        when(favoriteRepository.deleteByUserAndProduct(1L, 1L)).thenReturn(1);
        doReturn(1).when(productRepository).updateLikeCount(1L, -1);

        boolean result = favoriteService.toggleFavorite(1L, 1L);
        assertFalse(result);
    }

    @Test
    void isFavorited_ReturnsTrue() {
        when(favoriteRepository.findByUserAndProduct(1L, 1L)).thenReturn(new UserFavorite());
        assertTrue(favoriteService.isFavorited(1L, 1L));
    }

    @Test
    void isFavorited_ReturnsFalse() {
        when(favoriteRepository.findByUserAndProduct(1L, 1L)).thenReturn(null);
        assertFalse(favoriteService.isFavorited(1L, 1L));
    }

    @Test
    void getFavoriteList_Empty() {
        when(favoriteRepository.findProductIdsByUserId(1L)).thenReturn(List.of());
        var result = favoriteService.getFavoriteList(1L);
        assertTrue(result.isEmpty());
    }

    @Test
    void getFavoriteList_WithProducts_BatchImageQuery() {
        Product product = new Product();
        product.setId(1L);
        product.setTitle("银饰手镯");
        product.setPrice(new BigDecimal("599"));

        when(favoriteRepository.findProductIdsByUserId(1L)).thenReturn(List.of(1L));
        when(productRepository.findByIds(anyList())).thenReturn(List.of(product));

        Map<String, Object> imgRow = new HashMap<>();
        imgRow.put("product_id", 1L);
        imgRow.put("image_url", "http://img.jpg");
        when(productImageRepository.findImageUrlsByProductIds(anyList())).thenReturn(List.of(imgRow));

        var result = favoriteService.getFavoriteList(1L);

        assertEquals(1, result.size());
        assertEquals("银饰手镯", result.get(0).getTitle());
        verify(productImageRepository).findImageUrlsByProductIds(anyList());
    }

    @Test
    void getFavoriteProductIds_ReturnsIds() {
        when(favoriteRepository.findProductIdsByUserId(1L)).thenReturn(List.of(1L, 2L));
        List<Long> result = favoriteService.getFavoriteProductIds(1L);
        assertEquals(2, result.size());
    }
}

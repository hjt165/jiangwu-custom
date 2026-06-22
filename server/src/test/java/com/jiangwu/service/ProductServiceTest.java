package com.jiangwu.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangwu.common.PageResult;
import com.jiangwu.dto.response.ProductResponse;
import com.jiangwu.entity.Product;
import com.jiangwu.enums.ProductCategory;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.repository.ProductImageRepository;
import com.jiangwu.repository.ProductRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;

    @Mock
    private ProductImageRepository productImageRepository;

    @Mock
    private HistoryService historyService;

    @InjectMocks
    private ProductService productService;

    private Product testProduct;

    @BeforeEach
    void setUp() {
        testProduct = new Product();
        testProduct.setId(1L);
        testProduct.setTitle("手工陶瓷杯");
        testProduct.setDescription("精美的手工陶瓷杯");
        testProduct.setCategory(ProductCategory.CERAMIC);
        testProduct.setPrice(new BigDecimal("299.00"));
        testProduct.setArtisanId(1L);
        testProduct.setIsAvailable(true);
    }

    @Test
    void getProductDetail_Success() {
        when(productRepository.findById(anyLong())).thenReturn(testProduct);
        when(productRepository.incrementViewCount(anyLong())).thenReturn(1);

        ProductResponse response = productService.getProductDetail(1L);

        assertNotNull(response);
        assertEquals("手工陶瓷杯", response.getTitle());
        verify(productRepository, times(1)).incrementViewCount(anyLong());
    }

    @Test
    void getProductDetail_ProductNotFound_ThrowsException() {
        when(productRepository.findById(anyLong())).thenReturn(null);

        assertThrows(BusinessException.class, () -> productService.getProductDetail(1L));
    }

    @Test
    void searchProducts_Success() {
        List<Product> products = Arrays.asList(testProduct);
        when(productRepository.searchPage(any(Page.class), anyString())).thenAnswer(invocation -> {
            Page<Product> page = invocation.getArgument(0);
            page.setRecords(products);
            page.setTotal(1);
            return page;
        });
        when(productImageRepository.findImageUrlsByProductIds(anyList())).thenReturn(List.of());

        PageResult<ProductResponse> result = productService.searchProducts("陶瓷", 1, 10);

        assertNotNull(result);
        assertEquals(1, result.getTotal());
    }

    @Test
    void searchProducts_EmptyResult() {
        when(productRepository.searchPage(any(Page.class), anyString())).thenAnswer(invocation -> {
            Page<Product> page = invocation.getArgument(0);
            page.setRecords(List.of());
            page.setTotal(0);
            return page;
        });

        PageResult<ProductResponse> result = productService.searchProducts("不存在", 1, 10);

        assertNotNull(result);
        assertEquals(0, result.getTotal());
    }

    @Test
    void getProductList_WithCategory() {
        List<Product> products = Arrays.asList(testProduct);
        when(productRepository.findByCategoryPage(any(Page.class), any(ProductCategory.class))).thenAnswer(invocation -> {
            Page<Product> page = invocation.getArgument(0);
            page.setRecords(products);
            page.setTotal(1);
            return page;
        });
        when(productImageRepository.findImageUrlsByProductIds(anyList())).thenReturn(List.of());

        PageResult<ProductResponse> result = productService.getProductList(1, 10, "CERAMIC");

        assertNotNull(result);
        assertEquals(1, result.getTotal());
    }

    @Test
    void getProductList_AllCategories() {
        List<Product> products = Arrays.asList(testProduct);
        when(productRepository.findFeaturedPage(any(Page.class))).thenAnswer(invocation -> {
            Page<Product> page = invocation.getArgument(0);
            page.setRecords(products);
            page.setTotal(1);
            return page;
        });
        when(productImageRepository.findImageUrlsByProductIds(anyList())).thenReturn(List.of());

        PageResult<ProductResponse> result = productService.getProductList(1, 10, null);

        assertNotNull(result);
        assertEquals(1, result.getTotal());
    }

    @Test
    void getFeaturedProducts_ReturnsWithBatchImages() {
        when(productRepository.findFeatured()).thenReturn(List.of(testProduct));
        Map<String, Object> imgRow = new HashMap<>();
        imgRow.put("product_id", 1L);
        imgRow.put("image_url", "http://img.jpg");
        when(productImageRepository.findImageUrlsByProductIds(anyList())).thenReturn(List.of(imgRow));

        List<ProductResponse> result = productService.getFeaturedProducts();

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("手工陶瓷杯", result.get(0).getTitle());
        verify(productImageRepository).findImageUrlsByProductIds(anyList());
    }

    @Test
    void getArtisanProducts_ReturnsWithBatchImages() {
        when(productRepository.findByArtisanIdPage(any(Page.class), eq(1L))).thenAnswer(invocation -> {
            Page<Product> page = invocation.getArgument(0);
            page.setRecords(List.of(testProduct));
            page.setTotal(1);
            return page;
        });
        when(productImageRepository.findImageUrlsByProductIds(anyList())).thenReturn(List.of());

        PageResult<ProductResponse> result = productService.getArtisanProducts(1L, 1, 10);

        assertNotNull(result);
        assertEquals(1, result.getTotal());
    }
}

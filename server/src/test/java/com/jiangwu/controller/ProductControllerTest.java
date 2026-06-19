package com.jiangwu.controller;

import com.jiangwu.common.PageResult;
import com.jiangwu.dto.response.ProductResponse;
import com.jiangwu.service.AiService;
import com.jiangwu.exception.GlobalExceptionHandler;
import com.jiangwu.service.ProductService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 商品控制器测试
 */
class ProductControllerTest {

    private MockMvc mockMvc;
    private ProductService productService;
    private AiService aiService;
    private ProductResponse productResponse;

    @BeforeEach
    void setUp() {
        productService = mock(ProductService.class);
        aiService = mock(AiService.class);

        ProductController controller = new ProductController(productService, aiService);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();

        productResponse = new ProductResponse();
        productResponse.setId("1");
        productResponse.setTitle("手工陶瓷杯");
        productResponse.setDescription("精美的手工陶瓷杯");
        productResponse.setCategory("CERAMIC");
        productResponse.setPrice(299.00);
        productResponse.setArtisanId("1");
    }

    @Test
    void getProductList_Success() throws Exception {
        PageResult<ProductResponse> pageResult = new PageResult<>(
                1, List.of(productResponse), 1, 10, 1);

        when(productService.getProductList(anyInt(), anyInt(), any())).thenReturn(pageResult);

        mockMvc.perform(get("/product/list")
                        .param("page", "1")
                        .param("size", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.total").value(1));
    }

    @Test
    void getProductList_WithCategory() throws Exception {
        PageResult<ProductResponse> pageResult = new PageResult<>(
                1, List.of(productResponse), 1, 10, 1);

        when(productService.getProductList(anyInt(), anyInt(), anyString())).thenReturn(pageResult);

        mockMvc.perform(get("/product/list")
                        .param("page", "1")
                        .param("size", "10")
                        .param("category", "CERAMIC"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void getProductDetail_Success() throws Exception {
        when(productService.getProductDetail(1L)).thenReturn(productResponse);

        mockMvc.perform(get("/product/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.product.title").value("手工陶瓷杯"));
    }

    @Test
    void getProductDetail_NotFound() throws Exception {
        when(productService.getProductDetail(999L))
                .thenThrow(new RuntimeException("商品不存在"));

        mockMvc.perform(get("/product/999"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.code").value(500));
    }

    @Test
    void searchProducts_Success() throws Exception {
        PageResult<ProductResponse> pageResult = new PageResult<>(
                1, List.of(productResponse), 1, 10, 1);

        when(productService.searchProducts(anyString(), anyInt(), anyInt())).thenReturn(pageResult);

        mockMvc.perform(get("/product/search")
                        .param("keyword", "陶瓷")
                        .param("page", "1")
                        .param("size", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.total").value(1));
    }

    @Test
    void getFeaturedProducts_Success() throws Exception {
        when(productService.getFeaturedProducts()).thenReturn(List.of(productResponse));

        mockMvc.perform(get("/product/featured"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void getArtisanProducts_Success() throws Exception {
        PageResult<ProductResponse> pageResult = new PageResult<>(
                1, List.of(productResponse), 1, 10, 1);

        when(productService.getArtisanProducts(anyLong(), anyInt(), anyInt())).thenReturn(pageResult);

        mockMvc.perform(get("/product/artisan/1")
                        .param("page", "1")
                        .param("size", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }
}

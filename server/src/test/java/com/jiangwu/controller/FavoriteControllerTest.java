package com.jiangwu.controller;

import com.jiangwu.dto.response.ProductResponse;
import com.jiangwu.exception.GlobalExceptionHandler;
import com.jiangwu.service.FavoriteService;
import com.jiangwu.utils.CurrentUserUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 收藏控制器测试
 */
class FavoriteControllerTest {

    private MockMvc mockMvc;
    private FavoriteService favoriteService;
    private CurrentUserUtil currentUserUtil;

    @BeforeEach
    void setUp() {
        favoriteService = mock(FavoriteService.class);
        currentUserUtil = mock(CurrentUserUtil.class);

        FavoriteController controller = new FavoriteController(favoriteService, currentUserUtil);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void addFavorite_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);

        mockMvc.perform(post("/favorite/1")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void addFavorite_AlreadyFavorited() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        doThrow(new RuntimeException("已收藏该作品"))
                .when(favoriteService).addFavorite(anyLong(), anyLong());

        mockMvc.perform(post("/favorite/1")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.code").value(500));
    }

    @Test
    void removeFavorite_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);

        mockMvc.perform(delete("/favorite/1")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void toggleFavorite_Add() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(favoriteService.toggleFavorite(anyLong(), anyLong()))
                .thenReturn(true);

        mockMvc.perform(post("/favorite/1/toggle")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isFavorited").value(true));
    }

    @Test
    void toggleFavorite_Remove() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(favoriteService.toggleFavorite(anyLong(), anyLong()))
                .thenReturn(false);

        mockMvc.perform(post("/favorite/1/toggle")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isFavorited").value(false));
    }

    @Test
    void checkFavorite_True() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(favoriteService.isFavorited(anyLong(), anyLong())).thenReturn(true);

        mockMvc.perform(get("/favorite/check/1")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isFavorited").value(true));
    }

    @Test
    void checkFavorite_False() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(favoriteService.isFavorited(anyLong(), anyLong())).thenReturn(false);

        mockMvc.perform(get("/favorite/check/1")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isFavorited").value(false));
    }

    @Test
    void getFavoriteList_Success() throws Exception {
        ProductResponse product = new ProductResponse();
        product.setId("1");
        product.setTitle("收藏的商品");
        product.setPrice(199.00);

        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(favoriteService.getFavoriteList(anyLong()))
                .thenReturn(List.of(product));

        mockMvc.perform(get("/favorite/list")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }
}

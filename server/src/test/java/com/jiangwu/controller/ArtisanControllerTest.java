package com.jiangwu.controller;

import com.jiangwu.dto.response.ArtisanResponse;
import com.jiangwu.entity.Review;
import com.jiangwu.repository.ReviewRepository;
import com.jiangwu.exception.GlobalExceptionHandler;
import com.jiangwu.service.ArtisanFollowService;
import com.jiangwu.service.ArtisanService;
import com.jiangwu.utils.CurrentUserUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 手作人控制器测试
 */
class ArtisanControllerTest {

    private MockMvc mockMvc;
    private ArtisanService artisanService;
    private ArtisanFollowService artisanFollowService;
    private ReviewRepository reviewRepository;
    private CurrentUserUtil currentUserUtil;
    private ArtisanResponse artisanResponse;

    @BeforeEach
    void setUp() {
        artisanService = mock(ArtisanService.class);
        artisanFollowService = mock(ArtisanFollowService.class);
        reviewRepository = mock(ReviewRepository.class);
        currentUserUtil = mock(CurrentUserUtil.class);

        ArtisanController controller = new ArtisanController(
                artisanService, artisanFollowService, reviewRepository, currentUserUtil);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();

        artisanResponse = new ArtisanResponse();
        artisanResponse.setId("1");
        artisanResponse.setName("测试手作人");
        artisanResponse.setBio("专注陶瓷制作10年");
        artisanResponse.setSpecialty("CERAMIC");
        artisanResponse.setRating(4.8);
    }

    @Test
    void getArtisanList_Success() throws Exception {
        when(artisanService.getArtisanList())
                .thenReturn(List.of(artisanResponse));

        mockMvc.perform(get("/artisan/list"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void getArtisanDetail_Success() throws Exception {
        when(artisanService.getArtisanDetail(1L)).thenReturn(artisanResponse);

        mockMvc.perform(get("/artisan/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.name").value("测试手作人"));
    }

    @Test
    void getArtisanDetail_NotFound() throws Exception {
        when(artisanService.getArtisanDetail(999L))
                .thenThrow(new com.jiangwu.exception.BusinessException(com.jiangwu.exception.ErrorCode.ARTISAN_NOT_FOUND));

        mockMvc.perform(get("/artisan/999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(2001));
    }

    @Test
    void followArtisan_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(artisanFollowService.follow(1L, 1L)).thenReturn(Map.of("isFollowing", true));

        mockMvc.perform(post("/artisan/1/follow")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isFollowing").value(true));
    }

    @Test
    void unfollowArtisan_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(artisanFollowService.unfollow(1L, 1L)).thenReturn(Map.of("isFollowing", false));

        mockMvc.perform(delete("/artisan/1/follow")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isFollowing").value(false));
    }

    @Test
    void checkFollowStatus_True() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(artisanFollowService.isFollowing(1L, 1L)).thenReturn(true);

        mockMvc.perform(get("/artisan/1/follow/check")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isFollowing").value(true));
    }

    @Test
    void checkFollowStatus_False() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(artisanFollowService.isFollowing(1L, 1L)).thenReturn(false);

        mockMvc.perform(get("/artisan/1/follow/check")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isFollowing").value(false));
    }

    @Test
    void getArtisanReviews_Success() throws Exception {
        when(reviewRepository.findByArtisanId(anyLong()))
                .thenReturn(List.of());

        mockMvc.perform(get("/artisan/1/reviews"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }
}

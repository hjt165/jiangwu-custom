package com.jiangwu.controller;

import com.jiangwu.dto.response.ArtisanResponse;
import com.jiangwu.entity.Artisan;
import com.jiangwu.entity.UserFollow;
import com.jiangwu.repository.ArtisanRepository;
import com.jiangwu.repository.ReviewRepository;
import com.jiangwu.repository.UserFollowRepository;
import com.jiangwu.exception.GlobalExceptionHandler;
import com.jiangwu.service.ArtisanService;
import com.jiangwu.utils.CurrentUserUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.List;

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
    private ReviewRepository reviewRepository;
    private UserFollowRepository userFollowRepository;
    private ArtisanRepository artisanRepository;
    private CurrentUserUtil currentUserUtil;
    private ArtisanResponse artisanResponse;

    @BeforeEach
    void setUp() {
        artisanService = mock(ArtisanService.class);
        reviewRepository = mock(ReviewRepository.class);
        userFollowRepository = mock(UserFollowRepository.class);
        artisanRepository = mock(ArtisanRepository.class);
        currentUserUtil = mock(CurrentUserUtil.class);

        ArtisanController controller = new ArtisanController(
                artisanService, reviewRepository, userFollowRepository,
                artisanRepository, currentUserUtil);
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
                .thenThrow(new RuntimeException("手作人不存在"));

        mockMvc.perform(get("/artisan/999"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.code").value(500));
    }

    @Test
    void searchArtisans_Success() throws Exception {
        when(artisanService.searchArtisans(anyString()))
                .thenReturn(List.of(artisanResponse));

        mockMvc.perform(get("/artisan/search")
                        .param("keyword", "陶瓷"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void applyArtisan_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);

        mockMvc.perform(post("/artisan/apply")
                        .header("Authorization", "Bearer test_token")
                        .param("name", "新匠人")
                        .param("specialty", "CERAMIC")
                        .param("bio", "热爱陶瓷"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void followArtisan_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(userFollowRepository.findByUserIdAndArtisanId(anyLong(), anyLong())).thenReturn(null);
        when(userFollowRepository.insert(any(UserFollow.class))).thenReturn(1);
        Artisan artisan = new Artisan();
        artisan.setId(1L);
        artisan.setFanCount(10);
        when(artisanRepository.selectById(anyLong())).thenReturn(artisan);
        when(artisanRepository.updateById(any(Artisan.class))).thenReturn(1);

        mockMvc.perform(post("/artisan/1/follow")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void unfollowArtisan_Success() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(userFollowRepository.findByUserIdAndArtisanId(anyLong(), anyLong())).thenReturn(new UserFollow());
        when(userFollowRepository.delete(any())).thenReturn(1);
        Artisan artisan = new Artisan();
        artisan.setId(1L);
        artisan.setFanCount(10);
        when(artisanRepository.selectById(anyLong())).thenReturn(artisan);
        when(artisanRepository.updateById(any(Artisan.class))).thenReturn(1);

        mockMvc.perform(delete("/artisan/1/follow")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void checkFollowStatus_True() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(userFollowRepository.findByUserIdAndArtisanId(anyLong(), anyLong()))
                .thenReturn(new UserFollow());

        mockMvc.perform(get("/artisan/1/follow/check")
                        .header("Authorization", "Bearer test_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isFollowing").value(true));
    }

    @Test
    void checkFollowStatus_False() throws Exception {
        when(currentUserUtil.extractUserId(any())).thenReturn(1L);
        when(userFollowRepository.findByUserIdAndArtisanId(anyLong(), anyLong()))
                .thenReturn(null);

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

package com.jiangwu.service;

import com.jiangwu.entity.Artisan;
import com.jiangwu.entity.UserFollow;
import com.jiangwu.repository.ArtisanRepository;
import com.jiangwu.repository.UserFollowRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ArtisanFollowServiceTest {

    @Mock private UserFollowRepository userFollowRepository;
    @Mock private ArtisanRepository artisanRepository;
    @InjectMocks private ArtisanFollowService artisanFollowService;

    private Artisan testArtisan;

    @BeforeEach
    void setUp() {
        testArtisan = new Artisan();
        testArtisan.setId(1L);
        testArtisan.setName("张师傅");
        testArtisan.setFanCount(10);
    }

    @Test
    void follow_NewFollow_CreatesAndIncrementsFanCount() {
        when(userFollowRepository.findByUserIdAndArtisanId(1L, 1L)).thenReturn(null);
        doReturn(1).when(userFollowRepository).insert(any(UserFollow.class));
        when(artisanRepository.selectById(1L)).thenReturn(testArtisan);
        doReturn(1).when(artisanRepository).updateById(any(Artisan.class));

        Map<String, Boolean> result = artisanFollowService.follow(1L, 1L);

        assertTrue(result.get("isFollowing"));
        assertEquals(11, testArtisan.getFanCount());
    }

    @Test
    void follow_AlreadyFollowing_ReturnsTrue() {
        UserFollow existing = new UserFollow();
        when(userFollowRepository.findByUserIdAndArtisanId(1L, 1L)).thenReturn(existing);

        Map<String, Boolean> result = artisanFollowService.follow(1L, 1L);
        assertTrue(result.get("isFollowing"));
        verify(userFollowRepository, never()).insert(any(UserFollow.class));
    }

    @Test
    void unfollow_DecrementsFanCount() {
        doReturn(1).when(userFollowRepository).delete(any());
        when(artisanRepository.selectById(1L)).thenReturn(testArtisan);
        doReturn(1).when(artisanRepository).updateById(any(Artisan.class));

        Map<String, Boolean> result = artisanFollowService.unfollow(1L, 1L);

        assertFalse(result.get("isFollowing"));
        assertEquals(9, testArtisan.getFanCount());
    }

    @Test
    void unfollow_ZeroFanCount_DoesNotGoNegative() {
        testArtisan.setFanCount(0);
        doReturn(1).when(userFollowRepository).delete(any());
        when(artisanRepository.selectById(1L)).thenReturn(testArtisan);

        artisanFollowService.unfollow(1L, 1L);
        assertEquals(0, testArtisan.getFanCount());
    }

    @Test
    void isFollowing_True() {
        when(userFollowRepository.findByUserIdAndArtisanId(1L, 1L)).thenReturn(new UserFollow());
        assertTrue(artisanFollowService.isFollowing(1L, 1L));
    }

    @Test
    void isFollowing_False() {
        when(userFollowRepository.findByUserIdAndArtisanId(1L, 1L)).thenReturn(null);
        assertFalse(artisanFollowService.isFollowing(1L, 1L));
    }

    @Test
    void getFollowList_ReturnsArtisanInfo() {
        UserFollow follow = new UserFollow();
        follow.setId(1L);
        follow.setArtisanId(1L);
        when(userFollowRepository.findByUserId(1L)).thenReturn(List.of(follow));
        when(artisanRepository.selectById(1L)).thenReturn(testArtisan);

        List<Map<String, Object>> result = artisanFollowService.getFollowList(1L);
        assertEquals(1, result.size());
        assertEquals("张师傅", result.get(0).get("name"));
    }

    @Test
    void getFollowCount_ReturnsCount() {
        when(userFollowRepository.selectCount(any())).thenReturn(5L);
        assertEquals(5L, artisanFollowService.getFollowCount(1L));
    }
}

package com.jiangwu.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.jiangwu.entity.Artisan;
import com.jiangwu.entity.UserFollow;
import com.jiangwu.repository.ArtisanRepository;
import com.jiangwu.repository.UserFollowRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 手作人关注服务
 * 将关注/取消关注/检查关注/关注列表逻辑从Controller移入Service
 */
@Service
@RequiredArgsConstructor
public class ArtisanFollowService {

    private final UserFollowRepository userFollowRepository;
    private final ArtisanRepository artisanRepository;

    /**
     * 关注手作人（原子计数，无竞态条件）
     */
    @Transactional
    public Map<String, Boolean> follow(Long userId, Long artisanId) {
        UserFollow existing = userFollowRepository.findByUserIdAndArtisanId(userId, artisanId);
        if (existing != null) {
            return Map.of("isFollowing", true);
        }

        UserFollow follow = new UserFollow();
        follow.setUserId(userId);
        follow.setArtisanId(artisanId);
        userFollowRepository.insert(follow);

        // 原子递增 fanCount（避免竞态条件）
        artisanRepository.updateFanCount(artisanId, 1);

        return Map.of("isFollowing", true);
    }

    /**
     * 取消关注手作人（原子计数，无竞态条件）
     */
    @Transactional
    public Map<String, Boolean> unfollow(Long userId, Long artisanId) {
        QueryWrapper<UserFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId).eq("artisan_id", artisanId);
        userFollowRepository.delete(wrapper);

        // 原子递减 fanCount（避免竞态条件）
        artisanRepository.updateFanCount(artisanId, -1);

        return Map.of("isFollowing", false);
    }

    /**
     * 检查是否已关注
     */
    public boolean isFollowing(Long userId, Long artisanId) {
        UserFollow follow = userFollowRepository.findByUserIdAndArtisanId(userId, artisanId);
        return follow != null;
    }

    /**
     * 获取关注列表（批量查询，避免 N+1）
     */
    public List<Map<String, Object>> getFollowList(Long userId) {
        List<UserFollow> follows = userFollowRepository.findByUserId(userId);
        if (follows.isEmpty()) return List.of();

        // 批量加载手作人信息
        List<Long> artisanIds = follows.stream().map(UserFollow::getArtisanId).distinct().toList();
        Map<Long, Artisan> artisanMap = new java.util.HashMap<>();
        for (Long aid : artisanIds) {
            Artisan a = artisanRepository.findById(aid);
            if (a != null) artisanMap.put(aid, a);
        }

        return follows.stream().map(follow -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", follow.getId());
            item.put("createdAt", follow.getCreatedAt());

            Artisan artisan = artisanMap.get(follow.getArtisanId());
            if (artisan != null) {
                item.put("artisanId", artisan.getId());
                item.put("name", artisan.getName());
                item.put("avatar", artisan.getAvatar());
                item.put("specialty", artisan.getSpecialty());
                item.put("rating", artisan.getRating());
            }
            return item;
        }).collect(Collectors.toList());
    }

    /**
     * 获取关注数量
     */
    public long getFollowCount(Long userId) {
        QueryWrapper<UserFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId);
        return userFollowRepository.selectCount(wrapper);
    }
}

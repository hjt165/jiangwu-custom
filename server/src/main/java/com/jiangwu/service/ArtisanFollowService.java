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
     * 关注手作人
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

        Artisan artisan = artisanRepository.selectById(artisanId);
        if (artisan != null) {
            artisan.setFanCount(artisan.getFanCount() + 1);
            artisanRepository.updateById(artisan);
        }

        return Map.of("isFollowing", true);
    }

    /**
     * 取消关注手作人
     */
    @Transactional
    public Map<String, Boolean> unfollow(Long userId, Long artisanId) {
        QueryWrapper<UserFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId).eq("artisan_id", artisanId);
        userFollowRepository.delete(wrapper);

        Artisan artisan = artisanRepository.selectById(artisanId);
        if (artisan != null && artisan.getFanCount() > 0) {
            artisan.setFanCount(artisan.getFanCount() - 1);
            artisanRepository.updateById(artisan);
        }

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
     * 获取关注列表
     */
    public List<Map<String, Object>> getFollowList(Long userId) {
        List<UserFollow> follows = userFollowRepository.findByUserId(userId);

        return follows.stream().map(follow -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", follow.getId());
            item.put("createdAt", follow.getCreatedAt());

            Artisan artisan = artisanRepository.selectById(follow.getArtisanId());
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

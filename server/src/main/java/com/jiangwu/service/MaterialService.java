package com.jiangwu.service;

import com.jiangwu.entity.Material;
import com.jiangwu.repository.MaterialRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 材质服务
 */
@Service
@RequiredArgsConstructor
public class MaterialService {

    private final MaterialRepository materialRepository;

    /**
     * 获取所有材质
     */
    public List<Material> getAllMaterials() {
        return materialRepository.findAll();
    }

    /**
     * 按分类获取材质
     */
    public List<Material> getMaterialsByCategory(String category) {
        return materialRepository.findByCategory(category);
    }
}

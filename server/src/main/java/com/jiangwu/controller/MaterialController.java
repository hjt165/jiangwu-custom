package com.jiangwu.controller;

import com.jiangwu.common.Result;
import com.jiangwu.entity.Material;
import com.jiangwu.service.MaterialService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 材质控制器
 */
@Tag(name = "材质接口")
@RestController
@RequestMapping("/material")
@RequiredArgsConstructor
public class MaterialController {

    private final MaterialService materialService;

    /**
     * 获取所有材质
     */
    @Operation(summary = "获取所有材质")
    @GetMapping("/list")
    public Result<List<Material>> getAllMaterials() {
        return Result.success(materialService.getAllMaterials());
    }

    /**
     * 按分类获取材质
     */
    @Operation(summary = "按分类获取材质")
    @GetMapping("/category/{category}")
    public Result<List<Material>> getMaterialsByCategory(@PathVariable String category) {
        return Result.success(materialService.getMaterialsByCategory(category));
    }
}

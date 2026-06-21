package com.jiangwu.service;

import com.jiangwu.entity.Material;
import com.jiangwu.repository.MaterialRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MaterialServiceTest {

    @Mock private MaterialRepository materialRepository;
    @InjectMocks private MaterialService materialService;

    private Material testMaterial;

    @BeforeEach
    void setUp() {
        testMaterial = new Material();
        testMaterial.setId(1L);
        testMaterial.setCategory("jewelry");
        testMaterial.setName("925纯银");
        testMaterial.setDescription("高纯度银材");
        testMaterial.setSortOrder(1);
    }

    @Test
    void getAllMaterials_ReturnsList() {
        when(materialRepository.findAll()).thenReturn(List.of(testMaterial));

        List<Material> result = materialService.getAllMaterials();

        assertEquals(1, result.size());
        assertEquals("925纯银", result.get(0).getName());
    }

    @Test
    void getAllMaterials_EmptyList() {
        when(materialRepository.findAll()).thenReturn(List.of());

        List<Material> result = materialService.getAllMaterials();

        assertTrue(result.isEmpty());
    }

    @Test
    void getMaterialsByCategory_ReturnsFilteredList() {
        when(materialRepository.findByCategory("jewelry")).thenReturn(List.of(testMaterial));

        List<Material> result = materialService.getMaterialsByCategory("jewelry");

        assertEquals(1, result.size());
        assertEquals("jewelry", result.get(0).getCategory());
    }

    @Test
    void getMaterialsByCategory_EmptyForUnknownCategory() {
        when(materialRepository.findByCategory("unknown")).thenReturn(List.of());

        List<Material> result = materialService.getMaterialsByCategory("unknown");

        assertTrue(result.isEmpty());
    }
}

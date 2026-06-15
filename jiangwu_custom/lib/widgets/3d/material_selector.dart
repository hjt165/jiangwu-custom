import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 3D材质选择器组件
/// 用于选择和预览模型材质/颜色

class MaterialSelector extends StatelessWidget {
  final List<MaterialOption> materials;
  final String? selectedId;
  final Function(MaterialOption)? onSelected;

  const MaterialSelector({
    super.key,
    required this.materials,
    this.selectedId,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.palette,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '材质选择',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Wrap(
            spacing: AppSizes.spacingSmall,
            runSpacing: AppSizes.spacingSmall,
            children: materials.map((material) {
              final isSelected = material.id == selectedId;
              return _buildMaterialChip(
                material: material,
                isSelected: isSelected,
                onTap: onSelected != null ? () => onSelected!(material) : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialChip({
    required MaterialOption material,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingMedium,
          vertical: AppSizes.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (material.color != null)
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: AppSizes.spacingSmall),
                decoration: BoxDecoration(
                  color: material.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
              ),
            Text(
              material.name,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 材质选项
class MaterialOption {
  final String id;
  final String name;
  final Color? color;
  final String? textureUrl;
  final double? roughness;
  final double? metallic;

  MaterialOption({
    required this.id,
    required this.name,
    this.color,
    this.textureUrl,
    this.roughness,
    this.metallic,
  });
}

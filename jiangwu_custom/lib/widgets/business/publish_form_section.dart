import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 发布页表单区域（分类选择 + 需求描述）
class PublishFormSection extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final TextEditingController descriptionController;

  const PublishFormSection({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.descriptionController,
  });

  static const List<String> categories = ['首饰', '皮具', '陶瓷', '木艺', '绘画', '其他'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategorySection(),
        const SizedBox(height: AppSizes.spacingLarge),
        _buildDescriptionSection(),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '工艺分类',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        Wrap(
          spacing: AppSizes.spacingSmall,
          runSpacing: AppSizes.spacingSmall,
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                onCategoryChanged(selected ? category : null);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.white,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '需求描述',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        const Text(
          '请详细描述您的定制需求，包括材质、尺寸、颜色、雕刻内容等',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        TextFormField(
          controller: descriptionController,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: '请输入您的定制需求...',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入需求描述';
            }
            return null;
          },
        ),
      ],
    );
  }
}

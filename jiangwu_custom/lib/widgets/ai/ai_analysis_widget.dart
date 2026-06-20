import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// AI分析结果展示组件
/// 展示图片分析结果（颜色、风格、元素等）

class AiAnalysisWidget extends StatelessWidget {
  final List<Map<String, dynamic>>? colors;
  final List<String>? styleTags;
  final List<Map<String, dynamic>>? elements;
  final String? mood;
  final String? complexity;
  final String? summary;

  const AiAnalysisWidget({
    super.key,
    this.colors,
    this.styleTags,
    this.elements,
    this.mood,
    this.complexity,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSizes.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSizes.spacingMedium),
            if (summary != null) _buildSummary(),
            if (colors != null && colors!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingMedium),
              _buildColors(),
            ],
            if (styleTags != null && styleTags!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingMedium),
              _buildStyleTags(),
            ],
            if (elements != null && elements!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingMedium),
              _buildElements(),
            ],
            if (mood != null || complexity != null) ...[
              const SizedBox(height: AppSizes.spacingMedium),
              _buildMetadata(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.auto_awesome, color: AppColors.accent, size: 24),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          'AI分析结果',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 20),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Text(
              summary!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '色彩分析',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Wrap(
          spacing: AppSizes.spacingSmall,
          runSpacing: AppSizes.spacingSmall,
          children: colors!.map((color) {
            final hex = color['hex'] ?? '#000000';
            final name = color['name'] ?? '';
            final percentage = color['percentage'] ?? 0;
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingSmall,
                vertical: AppSizes.spacingXSmall,
              ),
              decoration: BoxDecoration(
                color: Color(int.parse('FF${hex.substring(1)}', radix: 16)),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Text(
                '$name ${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: _getContrastColor(hex),
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStyleTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '风格标签',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Wrap(
          spacing: AppSizes.spacingSmall,
          runSpacing: AppSizes.spacingSmall,
          children: styleTags!.map((tag) {
            return Chip(
              label: Text(tag),
              backgroundColor: AppColors.accent.withValues(alpha:0.1),
              labelStyle: TextStyle(color: AppColors.accent),
              padding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildElements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '设计元素',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        ...elements!.map((element) {
          final name = element['name'] ?? '';
          final confidence = element['confidence'] ?? 0;
          final description = element['description'];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (description != null)
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingSmall,
                    vertical: AppSizes.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Text(
                    '${(confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        if (mood != null)
          Expanded(
            child: _buildMetadataItem('氛围', mood!),
          ),
        if (complexity != null)
          Expanded(
            child: _buildMetadataItem('复杂度', complexity!),
          ),
      ],
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXSmall),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取对比色（用于文字）
  Color _getContrastColor(String hex) {
    final color = Color(int.parse('FF${hex.substring(1)}', radix: 16));
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? AppColors.black : AppColors.white;
  }
}

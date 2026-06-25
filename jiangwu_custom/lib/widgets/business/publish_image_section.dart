import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../common/platform_image.dart';

/// 发布页图片上传区域
class PublishImageSection extends StatelessWidget {
  final List<String> images;
  final VoidCallback onAddImage;
  final ValueChanged<String> onRemoveImage;

  const PublishImageSection({
    super.key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '上传图片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        const Text(
          '支持JPG/PNG格式，单图≤10MB，最多9张',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        Wrap(
          spacing: AppSizes.spacingSmall,
          runSpacing: AppSizes.spacingSmall,
          children: [
            ...images.map((image) => _buildSelectedImage(
              image,
              onRemove: () => onRemoveImage(image),
            )),
            if (images.length < 9)
              GestureDetector(
                onTap: onAddImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(
                      color: AppColors.divider,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 24,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '添加图片',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedImage(String imagePath, {required VoidCallback onRemove}) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            child: imagePath.startsWith('http')
                ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image, size: 24, color: AppColors.textHint),
                    ),
                  )
                : buildLocalImage(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

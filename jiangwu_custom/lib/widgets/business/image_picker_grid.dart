import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/constants.dart';

/// 图片选择网格组件
/// 支持从相册/相机选择图片，最多maxImages张

class ImagePickerGrid extends StatelessWidget {
  final List<String> images;
  final int maxImages;
  final ValueChanged<List<String>> onImagesChanged;
  final bool enableDelete;

  const ImagePickerGrid({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.maxImages = 9,
    this.enableDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...images.asMap().entries.map((entry) {
          return _buildImageItem(context, entry.key, entry.value);
        }),
        if (images.length < maxImages) _buildAddButton(context),
      ],
    );
  }

  Widget _buildImageItem(BuildContext context, int index, String imageUrl) {
    final isLocal = imageUrl.startsWith('/') || imageUrl.startsWith('file:');

    return Stack(
      children: [
        GestureDetector(
          onTap: () => _previewImage(context, imageUrl),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              color: AppColors.divider,
            ),
            child: isLocal
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    child: Image.file(
                      File(imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
                  ),
          ),
        ),
        if (enableDelete)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          color: AppColors.divider,
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28,
              color: AppColors.textHint,
            ),
            SizedBox(height: 4),
            Text(
              '添加',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        size: 30,
        color: AppColors.textHint,
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages(ImageSource source) async {
    final picker = ImagePicker();
    final remaining = maxImages - images.length;

    if (remaining <= 0) return;

    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1024,
      limit: remaining,
    );

    if (pickedFiles.isNotEmpty) {
      final newImages = [...images, ...pickedFiles.map((f) => f.path)];
      onImagesChanged(newImages);
    }
  }

  void _removeImage(int index) {
    final newImages = List<String>.from(images)..removeAt(index);
    onImagesChanged(newImages);
  }

  void _previewImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ImagePreviewPage(imageUrl: imageUrl),
      ),
    );
  }
}

/// 图片预览页面
class _ImagePreviewPage extends StatelessWidget {
  final String imageUrl;

  const _ImagePreviewPage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isLocal = imageUrl.startsWith('/') || imageUrl.startsWith('file:');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: isLocal
              ? Image.file(
                  File(imageUrl),
                  fit: BoxFit.contain,
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}

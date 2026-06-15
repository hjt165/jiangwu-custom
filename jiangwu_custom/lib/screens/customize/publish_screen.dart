import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/constants.dart';

/// 需求发布页
/// 多模态输入（图片/文字/语音）

class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  List<String> _selectedImages = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog() {
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
    final remaining = 9 - _selectedImages.length;

    if (remaining <= 0) return;

    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1024,
      limit: remaining,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = [..._selectedImages, ...pickedFiles.map((f) => f.path)];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布需求'),
        actions: [
          TextButton(
            onPressed: () => _handlePublish(),
            child: const Text(
              '发布',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片上传区域
              _buildImageUploadSection(),

              const SizedBox(height: AppSizes.spacingLarge),

              // 工艺分类选择
              _buildCategorySection(),

              const SizedBox(height: AppSizes.spacingLarge),

              // 需求描述
              _buildDescriptionSection(),

              const SizedBox(height: AppSizes.spacingLarge),

              // 参考图片
              _buildReferenceSection(),

              const SizedBox(height: AppSizes.spacingLarge),

              // 提交按钮
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
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
            // 已选择的图片
            ..._selectedImages.map((image) => _buildSelectedImage(image)),

            // 添加图片按钮
            if (_selectedImages.length < 9)
              GestureDetector(
                onTap: () => _showImageSourceDialog(),
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

  Widget _buildSelectedImage(String imagePath) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: const Center(
            child: Icon(
              Icons.image,
              size: 24,
              color: AppColors.textHint,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImages.remove(imagePath);
              });
            },
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

  Widget _buildCategorySection() {
    final categories = ['首饰', '皮具', '陶瓷', '木艺', '绘画', '其他'];

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
            final isSelected = _selectedCategory == category;
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
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
          controller: _descriptionController,
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

  Widget _buildReferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '参考图片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        const Text(
          '上传参考图片，帮助手作人更好地理解您的需求',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        GestureDetector(
          onTap: () => _showImageSourceDialog(),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: AppColors.divider,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    '点击上传参考图片',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handlePublish(),
        child: const Text('发布需求'),
      ),
    );
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择工艺分类'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请至少上传一张图片'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final response = await ApiService().post<Map<String, dynamic>>(
        '/order/create',
        data: {
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'images': _selectedImages,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('需求发布成功，等待手作人响应'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发布失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

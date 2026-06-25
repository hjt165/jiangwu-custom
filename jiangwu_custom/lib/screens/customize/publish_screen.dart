import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/constants.dart';
import '../../services/api_service.dart';
import '../../widgets/business/publish_image_section.dart';
import '../../widgets/business/publish_form_section.dart';

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
  List<String> _images = [];
  bool _isPublishing = false;

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
    final remaining = 9 - _images.length;

    if (remaining <= 0) return;

    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1024,
      limit: remaining,
    );

    if (pickedFiles.isNotEmpty && mounted) {
      setState(() {
        _images = [..._images, ...pickedFiles.map((f) => f.path)];
      });
    }
  }

  Future<List<String>> _uploadImages(List<String> imagePaths) async {
    final api = ApiService();
    final urls = <String>[];
    for (final path in imagePaths) {
      try {
        final result = await api.upload<Map<String, dynamic>>(
          '/file/upload',
          filePath: path,
          fromJson: (data) => Map<String, dynamic>.from(data),
        );
        if (result['url'] != null) {
          urls.add(result['url']);
        }
      } catch (e) {
        debugPrint('图片上传失败: $e');
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '发布需求',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: _isPublishing ? null : () => _handlePublish(),
                    child: const Text('发布'),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              PublishImageSection(
                images: _images,
                onAddImage: _showImageSourceDialog,
                onRemoveImage: (image) {
                  setState(() {
                    _images.remove(image);
                  });
                },
              ),
              const SizedBox(height: AppSizes.spacingLarge),
              PublishFormSection(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                descriptionController: _descriptionController,
              ),
              const SizedBox(height: AppSizes.spacingLarge),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPublishing ? null : () => _handlePublish(),
        child: _isPublishing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Text('发布需求'),
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

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请至少上传一张图片'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final uploadedUrls = await _uploadImages(_images);

      await ApiService().post<Map<String, dynamic>>(
        '/order/create',
        data: {
          'specialRequests': _descriptionController.text,
          'referenceImages': uploadedUrls,
          'remark': '分类: $_selectedCategory',
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('需求发布成功，等待手作人响应'),
            backgroundColor: AppColors.success,
          ),
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          _formKey.currentState?.reset();
          setState(() {
            _images.clear();
            _selectedCategory = null;
            _descriptionController.clear();
          });
        }
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
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }
}

import 'package:flutter/material.dart';
import '../../app/constants.dart';
import 'image_picker_grid.dart';
import '../common/app_card.dart';

/// 反馈表单组件
/// 用于阶段确认时提交反馈

enum FeedbackType {
  approve('通过', Icons.check_circle_outline, AppColors.success),
  revise('申请修改', Icons.edit_outlined, AppColors.accent);

  final String label;
  final IconData icon;
  final Color color;

  const FeedbackType(this.label, this.icon, this.color);
}

class FeedbackForm extends StatefulWidget {
  final ValueChanged<FeedbackFormData> onSubmit;
  final bool isLoading;

  const FeedbackForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<FeedbackForm> createState() => FeedbackFormState();
}

class FeedbackFormData {
  final FeedbackType type;
  final String content;
  final List<String> images;

  const FeedbackFormData({
    required this.type,
    required this.content,
    required this.images,
  });
}

class FeedbackFormState extends State<FeedbackForm> {
  FeedbackType _feedbackType = FeedbackType.approve;
  final TextEditingController _contentController = TextEditingController();
  List<String> _selectedImages = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Row(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSizes.spacingSmall),
                Text(
                  '反馈内容',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // 反馈类型选择
            _buildFeedbackTypeSelector(),
            const SizedBox(height: AppSizes.paddingMedium),

            // 反馈文字
            _buildContentInput(),
            const SizedBox(height: AppSizes.paddingMedium),

            // 反馈图片
            _buildImageSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackTypeSelector() {
    return Row(
      children: FeedbackType.values.map((type) {
        final isSelected = _feedbackType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _feedbackType = type;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppSizes.spacingSmall),
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.paddingMedium,
                horizontal: AppSizes.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: isSelected ? type.color.withValues(alpha: 0.1) : AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: isSelected ? type.color : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type.icon,
                    size: 18,
                    color: isSelected ? type.color : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? type.color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContentInput() {
    return TextFormField(
      controller: _contentController,
      maxLines: 4,
      maxLength: 500,
      validator: (value) {
        if (_feedbackType == FeedbackType.revise && (value == null || value.trim().isEmpty)) {
          return '申请修改时请填写修改意见';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: _feedbackType == FeedbackType.approve
            ? '确认通过，可添加备注（选填）'
            : '请描述需要修改的内容...',
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textHint,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '反馈图片 (选填，最多3张)',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        ImagePickerGrid(
          images: _selectedImages,
          maxImages: 3,
          enableDelete: true,
          onImagesChanged: (images) {
            setState(() {
              _selectedImages = images;
            });
          },
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final formData = FeedbackFormData(
      type: _feedbackType,
      content: _contentController.text.trim(),
      images: _selectedImages,
    );

    widget.onSubmit(formData);
  }

  /// 暴露提交方法给父组件
  void submit() => _handleSubmit();
}

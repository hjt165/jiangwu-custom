import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../services/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _contentController = TextEditingController();
  final _contactController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _contentController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_contentController.text.trim().isEmpty) return;
    setState(() => _submitted = true);
    try {
      await ApiService().submitFeedback(
        _contentController.text.trim(),
        contact: _contactController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('感谢您的反馈！')),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitted = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提交失败，请重试'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('意见反馈')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '反馈内容',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            TextField(
              controller: _contentController,
              maxLines: 5,
              enabled: !_submitted,
              decoration: InputDecoration(
                hintText: '请描述您遇到的问题或建议...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            const Text(
              '联系方式（选填）',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            TextField(
              controller: _contactController,
              enabled: !_submitted,
              decoration: InputDecoration(
                hintText: '手机号或邮箱，方便我们联系您',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: AppSizes.spacingLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitted ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                ),
                child: Text(_submitted ? '已提交' : '提交反馈', style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 加载动画组件
/// 支持全屏加载和内联加载

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool fullscreen;

  const LoadingWidget({
    super.key,
    this.message,
    this.fullscreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          color: AppColors.primary,
        ),
        if (message != null) ...[
          const SizedBox(height: AppSizes.spacingMedium),
          Text(
            message!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );

    if (fullscreen) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

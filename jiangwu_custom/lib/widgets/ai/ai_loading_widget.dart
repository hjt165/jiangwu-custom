import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../common/app_card.dart';

/// AI加载状态组件
/// 展示AI分析/推荐过程中的加载状态

class AiLoadingWidget extends StatefulWidget {
  final String message;
  final bool showProgress;

  const AiLoadingWidget({
    super.key,
    this.message = 'AI正在分析中...',
    this.showProgress = true,
  });

  @override
  State<AiLoadingWidget> createState() => _AiLoadingWidgetState();
}

class _AiLoadingWidgetState extends State<AiLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        margin: const EdgeInsets.all(AppSizes.spacingMedium),
        padding: const EdgeInsets.all(AppSizes.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AI图标动画
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withValues(alpha:0.3 + _animation.value * 0.4),
                        AppColors.accent.withValues(alpha:0.6 + _animation.value * 0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppColors.white,
                    size: 40,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            // 加载消息
            Text(
              widget.message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.showProgress) ...[
              const SizedBox(height: AppSizes.spacingMedium),
              // 进度指示器
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.spacingMedium),
            // 提示文字
            Text(
              '正在使用AI技术进行智能分析，请稍候...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// AI分析进度组件
/// 展示多步骤分析进度

class AiProgressWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> steps;

  const AiProgressWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.all(AppSizes.spacingMedium),
      padding: const EdgeInsets.all(AppSizes.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                'AI分析进度',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$currentStep/$totalSteps',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          // 步骤列表
          ...List.generate(steps.length, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success
                          : isCurrent
                              ? AppColors.accent
                              : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? Icon(Icons.check, color: AppColors.white, size: 16)
                        : isCurrent
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : null,
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: Text(
                      steps[index],
                      style: TextStyle(
                        color: isCompleted
                            ? AppColors.textSecondary
                            : isCurrent
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                        fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

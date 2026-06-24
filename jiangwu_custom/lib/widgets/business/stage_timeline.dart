import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../../utils/date_utils.dart';
import '../../models/order.dart';
import '../common/app_card.dart';

/// 阶段时间线组件
/// 展示订单各阶段的进度和状态

class StageTimeline extends StatelessWidget {
  final List<OrderStage> stages;
  final int currentStage;

  const StageTimeline({
    super.key,
    required this.stages,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    if (stages.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Row(
            children: [
              Icon(
                Icons.timeline,
                size: 20,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '制作进度',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // 时间线
          ...List.generate(stages.length, (index) {
            final stage = stages[index];
            final isCompleted = index < currentStage;
            final isCurrent = index == currentStage;
            final isLast = index == stages.length - 1;

            return _buildStageItem(
              stage: stage,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStageItem({
    required OrderStage stage,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    final color = isCompleted
        ? AppColors.success
        : isCurrent
            ? AppColors.primary
            : AppColors.textHint;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧时间线
          SizedBox(
            width: 30,
            child: Column(
              children: [
                // 圆点
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent ? color : AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.white,
                        )
                      : isCurrent
                          ? Container(
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                ),
                // 连接线
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? color : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacingSmall),

          // 右侧内容
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 阶段名称
                  Text(
                    stage.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 阶段描述
                  if (stage.description.isNotEmpty)
                    Text(
                      stage.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                  // 完成时间
                  if (stage.completedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '完成于 ${AppDateUtils.formatYMDHM(stage.completedAt!)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),

                  // 交付图片
                  if (stage.deliverImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: stage.deliverImages.take(3).map((imageUrl) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // 交付备注
                  if (stage.deliverNote != null && stage.deliverNote!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingSmall),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                        child: Text(
                          stage.deliverNote!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

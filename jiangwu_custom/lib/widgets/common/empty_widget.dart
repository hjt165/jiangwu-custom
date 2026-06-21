import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 空状态组件（原始版本）
/// 用于列表为空时的提示展示

class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyWidget({
    super.key,
    this.message = AppStrings.noData,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSizes.spacingLarge),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 订单空状态
class EmptyOrderWidget extends StatelessWidget {
  final VoidCallback? onBrowse;

  const EmptyOrderWidget({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.receipt_long_rounded,
      message: '暂无订单',
      actionText: '去逛逛',
      onAction: onBrowse,
    );
  }
}

/// 搜索空状态
class EmptySearchWidget extends StatelessWidget {
  final String? keyword;

  const EmptySearchWidget({super.key, this.keyword});

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.search_off_rounded,
      message: keyword != null ? '没有找到与"$keyword"相关的结果' : '换个关键词试试',
    );
  }
}

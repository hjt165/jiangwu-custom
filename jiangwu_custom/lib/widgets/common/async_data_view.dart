import 'package:flutter/material.dart';
import '../../app/constants.dart';
import 'loading_widget.dart';
import 'error_widget.dart';
import 'empty_widget.dart';

/// 异步数据视图封装
/// 统一处理加载中/错误/空状态/有数据四种状态
/// 消除各屏幕中重复的 isLoading/error/empty 判断逻辑
///
/// 用法示例:
/// ```dart
/// AsyncDataView(
///   isLoading: state.isLoading && state.items.isEmpty,
///   error: state.error,
///   isEmpty: state.items.isEmpty,
///   onRetry: () => ref.read(provider.notifier).fetchData(),
///   emptyIcon: Icons.inbox_outlined,
///   emptyMessage: '暂无数据',
///   builder: (context) => _buildContent(state),
/// )
/// ```

class AsyncDataView extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final bool isEmpty;
  final VoidCallback? onRetry;
  final IconData emptyIcon;
  final String emptyMessage;
  final String? emptyActionText;
  final VoidCallback? onEmptyAction;
  final String? emptySubtitle;
  final WidgetBuilder builder;

  const AsyncDataView({
    super.key,
    required this.isLoading,
    this.error,
    required this.isEmpty,
    this.onRetry,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyMessage = AppStrings.noData,
    this.emptyActionText,
    this.onEmptyAction,
    this.emptySubtitle,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingWidget();
    }

    if (error != null && isEmpty) {
      return CustomErrorWidget(
        message: error!,
        onRetry: onRetry,
      );
    }

    if (isEmpty) {
      return EmptyWidget(
        icon: emptyIcon,
        message: emptyMessage,
        actionText: emptyActionText,
        onAction: onEmptyAction,
        subtitle: emptySubtitle,
      );
    }

    return builder(context);
  }
}

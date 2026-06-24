import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 底部操作栏容器
/// 统一处理安全区域、背景色、阴影、内边距
class BottomBarContainer extends StatelessWidget {
  const BottomBarContainer({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.shadowColor,
    this.elevation,
  });

  /// 子组件（通常是 Row 或 Column）
  final Widget child;

  /// 自定义内边距（默认包含底部安全区域）
  final EdgeInsetsGeometry? padding;

  /// 背景色
  final Color? backgroundColor;

  /// 阴影颜色
  final Color? shadowColor;

  /// 阴影高度
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeAreaBottom = mediaQuery.padding.bottom;

    return Container(
      padding: padding ??
          EdgeInsets.only(
            left: AppSizes.paddingMedium,
            right: AppSizes.paddingMedium,
            top: AppSizes.paddingMedium,
            bottom: safeAreaBottom + AppSizes.paddingMedium,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? Colors.black.withValues(alpha: 0.05),
            blurRadius: elevation ?? 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: child,
      ),
    );
  }
}

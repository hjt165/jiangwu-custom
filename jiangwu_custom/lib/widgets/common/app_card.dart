import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 通用卡片容器组件
/// 封装白底+圆角+阴影的重复样式
///
/// 用法示例:
/// ```dart
/// AppCard(
///   margin: EdgeInsets.only(bottom: AppSizes.paddingMedium),
///   padding: const EdgeInsets.all(AppSizes.paddingMedium),
///   child: Text('内容'),
/// )
/// ```
///
/// 或无 margin:
/// ```dart
/// AppCard(
///   child: Text('内容'),
/// )
/// ```

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(AppSizes.paddingMedium),
    this.color = AppColors.white,
    this.borderRadius = AppSizes.radiusMedium,
    this.boxShadow = AppSizes.cardShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

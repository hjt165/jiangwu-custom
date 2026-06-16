import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 通用弹窗组件
/// 提供确认弹窗、输入弹窗、选择弹窗等

class AppDialog {
  AppDialog._();

  /// 显示确认弹窗
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '确认',
    String cancelText = '取消',
    Color? confirmColor,
    bool barrierDismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(color: confirmColor ?? AppColors.accent),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示输入弹窗
  static Future<String?> showInput(
    BuildContext context, {
    required String title,
    String? hintText,
    String? initialValue,
    int maxLength = 100,
    int maxLines = 1,
    String confirmText = '确认',
    String cancelText = '取消',
    TextInputType? keyboardType,
    bool barrierDismissible = true,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              cancelText,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(
              confirmText,
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  /// 显示选择弹窗
  static Future<int?> showSelect(
    BuildContext context, {
    required String title,
    required List<String> options,
    int? selectedIndex,
    String confirmText = '确认',
    String cancelText = '取消',
    bool barrierDismissible = true,
  }) async {
    int selected = selectedIndex ?? -1;
    final result = await showDialog<int>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(options.length, (index) {
              return RadioListTile<int>(
                title: Text(options[index]),
                value: index,
                groupValue: selected,
                onChanged: (value) {
                  setState(() => selected = value ?? -1);
                },
                activeColor: AppColors.accent,
              );
            }),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                cancelText,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selected),
              child: Text(
                confirmText,
                style: TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
    return result;
  }

  /// 显示底部弹窗
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
  }) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: barrierDismissible ? Colors.black54 : null,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLarge),
          ),
        ),
        child: child,
      ),
    );
    return result;
  }

  /// 显示加载弹窗
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.accent),
              if (message != null) ...[
                const SizedBox(height: AppSizes.spacingMedium),
                Text(
                  message,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
        ),
      ),
    );
  }

  /// 关闭加载弹窗
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// 显示成功提示
  static void showSuccess(BuildContext context, String message, {VoidCallback? onDismissed}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 64,
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismissed?.call();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示错误提示
  static void showError(BuildContext context, String message, {VoidCallback? onDismissed}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismissed?.call();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

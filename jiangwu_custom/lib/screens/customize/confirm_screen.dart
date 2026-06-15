import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../providers/customization_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/business/customize_params_card.dart';
import '../../widgets/business/price_detail_card.dart';
import '../../widgets/common/button_widget.dart';

/// 方案确认页面
/// 用户确认定制参数，查看报价，提交订单

class ConfirmScreen extends ConsumerStatefulWidget {
  const ConfirmScreen({super.key});

  @override
  ConsumerState<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  bool _isSubmitting = false;

  // 模拟报价数据（后续接入AI报价接口）
  final double _materialCost = 280.0;
  final double _laborCost = 450.0;
  final int _estimatedDays = 10;
  final String _difficulty = '中等';

  @override
  Widget build(BuildContext context) {
    final customizationState = ref.watch(customizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('方案确认'),
      ),
      body: _buildBody(customizationState),
      bottomNavigationBar: _buildBottomBar(customizationState),
    );
  }

  Widget _buildBody(CustomizationProvider customizationState) {
    final customization = customizationState.buildCustomization();

    if (!customizationState.isValid) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            const Text(
              '暂无定制参数',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            const Text(
              '请先发布定制需求',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 定制参数
          CustomizeParamsCard(customization: customization),
          const SizedBox(height: AppSizes.paddingMedium),

          // 参考图片
          if (customization.referenceImages.isNotEmpty) ...[
            _buildReferenceImages(customization.referenceImages),
            const SizedBox(height: AppSizes.paddingMedium),
          ],

          // 报价明细
          PriceDetailCard(
            materialCost: _materialCost,
            laborCost: _laborCost,
            estimatedDays: _estimatedDays,
            difficulty: _difficulty,
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // 温馨提示
          _buildTips(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildReferenceImages(List<String> images) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '参考图片',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: images.take(9).map((imageUrl) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  color: AppColors.divider,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_outlined,
                        color: AppColors.textHint,
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '温馨提示',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          const Text(
            '1. 确认方案后将进入制作流程\n'
            '2. 手作人会在制作过程中更新进度\n'
            '3. 每个阶段完成后需要您确认\n'
            '4. 如有问题可随时联系手作人',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CustomizationProvider customizationState) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.paddingMedium,
        right: AppSizes.paddingMedium,
        top: AppSizes.paddingMedium,
        bottom: MediaQuery.of(context).padding.bottom + AppSizes.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 修改方案按钮
          Expanded(
            child: ButtonWidget(
              text: '修改方案',
              isOutlined: true,
              onPressed: _isSubmitting ? null : _handleModify,
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          // 确认提交按钮
          Expanded(
            child: ButtonWidget(
              text: _isSubmitting ? '提交中...' : '确认提交',
              isLoading: _isSubmitting,
              onPressed: _isSubmitting || !customizationState.isValid
                  ? null
                  : _handleSubmit,
            ),
          ),
        ],
      ),
    );
  }

  void _handleModify() {
    Navigator.of(context).pop();
  }

  void _handleSubmit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final customizationState = ref.read(customizationProvider);
      final customization = customizationState.buildCustomization();
      final product = customizationState.selectedProduct;

      // 创建订单
      final order = await ref.read(orderProvider.notifier).createOrder(
            productId: product?.id ?? '',
            artisanId: product?.artisanId ?? '',
            customization: customization.toJson(),
            amount: _materialCost + _laborCost,
          );

      if (mounted) {
        if (order != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('订单创建成功'),
              backgroundColor: AppColors.success,
            ),
          );

          // 清空定制参数
          customizationState.reset();

          // 跳转到订单详情页
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.orderDetail,
            (route) => route.isFirst,
            arguments: order.id,
          );
        } else {
          final error = ref.read(orderProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? '提交失败，请重试'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

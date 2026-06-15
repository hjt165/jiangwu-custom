import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../services/payment_service.dart';
import '../../widgets/business/payment_method_selector.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/button_widget.dart';

/// 支付页面
/// 用户选择支付方式，完成订单支付

class PayScreen extends ConsumerStatefulWidget {
  final String orderId;

  const PayScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends ConsumerState<PayScreen> {
  PaymentMethod _paymentMethod = PaymentMethod.alipay;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderProvider.notifier).fetchOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('确认支付'),
      ),
      body: _buildBody(orderState),
      bottomNavigationBar: orderState.currentOrder != null
          ? _buildBottomBar(orderState.currentOrder!)
          : null,
    );
  }

  Widget _buildBody(OrderProvider orderState) {
    if (orderState.isLoading && orderState.currentOrder == null) {
      return const LoadingWidget();
    }

    if (orderState.error != null && orderState.currentOrder == null) {
      return CustomErrorWidget(
        message: orderState.error!,
        onRetry: () {
          ref.read(orderProvider.notifier).fetchOrderDetail(widget.orderId);
        },
      );
    }

    if (orderState.currentOrder == null) {
      return const Center(
        child: Text('订单不存在', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final order = orderState.currentOrder!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 订单信息
          _buildOrderInfo(order),
          const SizedBox(height: AppSizes.paddingMedium),

          // 支付金额
          _buildAmountCard(order),
          const SizedBox(height: AppSizes.paddingMedium),

          // 支付方式
          PaymentMethodSelector(
            selected: _paymentMethod,
            onSelected: (method) {
              setState(() {
                _paymentMethod = method;
              });
            },
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // 支付须知
          _buildPaymentNotice(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(Order order) {
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
                Icons.receipt_long,
                size: 20,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '订单信息',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildInfoRow('订单编号', order.orderNo),
          _buildInfoRow('商品名称', order.product?.title ?? '定制作品'),
          if (order.artisan != null)
            _buildInfoRow('手作人', order.artisan!.name),
          _buildInfoRow('下单时间', _formatDateTime(order.createdAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(Order order) {
    final amount = order.totalAmount - order.paidAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _paymentMethod.label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            '¥${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            '应付金额',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '支付须知',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          const Text(
            '1. 支付完成后，手作人将开始制作\n'
            '2. 制作过程中会分阶段更新进度\n'
            '3. 每个阶段完成后需要您确认\n'
            '4. 如有问题可随时联系手作人',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textHint,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Order order) {
    final amount = order.totalAmount - order.paidAmount;

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
      child: ButtonWidget(
        text: _isPaying ? '支付中...' : '确认支付 ¥${amount.toStringAsFixed(2)}',
        isLoading: _isPaying,
        onPressed: _isPaying ? null : _handlePay,
      ),
    );
  }

  void _handlePay() async {
    if (_isPaying) return;

    setState(() {
      _isPaying = true;
    });

    final order = ref.read(orderProvider).currentOrder;
    if (order == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('订单信息不存在'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() { _isPaying = false; });
      }
      return;
    }

    final amount = order.totalAmount - order.paidAmount;

    try {
      final paymentService = PaymentService();
      final result = await paymentService.pay(
        orderId: order.id,
        amount: amount,
        description: '匠物定制-订单${order.orderNo}',
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('支付成功'),
              backgroundColor: AppColors.success,
            ),
          );

          await ref.read(orderProvider.notifier).fetchOrderDetail(widget.orderId);

          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.orderDetail,
              (route) => route.isFirst,
              arguments: widget.orderId,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMsg),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('支付失败：$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

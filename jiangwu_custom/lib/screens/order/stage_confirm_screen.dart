import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/business/stage_deliver_card.dart';
import '../../widgets/business/feedback_form.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/button_widget.dart';
import '../chat/chat_screen.dart';

/// 阶段确认页面
/// 用户确认手作人交付的阶段成果，提交反馈

class StageConfirmScreen extends ConsumerStatefulWidget {
  final String orderId;

  const StageConfirmScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<StageConfirmScreen> createState() => _StageConfirmScreenState();
}

class _StageConfirmScreenState extends ConsumerState<StageConfirmScreen> {
  final GlobalKey<FeedbackFormState> _feedbackFormKey = GlobalKey<FeedbackFormState>();
  bool _isSubmitting = false;

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
        title: const Text('阶段确认'),
        actions: [
          IconButton(
            onPressed: () async {
              final order = ref.read(orderProvider).currentOrder;
              if (order != null) {
                final user = ref.read(authServiceProvider).currentUser;
                if (user != null && order.artisanId != null) {
                  try {
                    final chatService = ref.read(chatServiceProvider);
                    final conversation = await chatService.getOrCreateConversation(
                      user.id,
                      order.artisanId!,
                      orderId: int.tryParse(order.id),
                    );
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            conversationId: conversation.id,
                            otherName: order.artisan?.name ?? '手作人',
                            otherAvatar: order.artisan?.avatar,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('创建会话失败: $e')),
                      );
                    }
                  }
                }
              }
            },
            icon: const Icon(Icons.chat_outlined),
          ),
        ],
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
    final currentStage = order.currentStageDetail;

    if (currentStage == null) {
      return const Center(
        child: Text('当前无可确认阶段', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 阶段信息
          _buildStageInfo(currentStage),
          const SizedBox(height: AppSizes.paddingMedium),

          // 交付内容
          StageDeliverCard(stage: currentStage),
          const SizedBox(height: AppSizes.paddingMedium),

          // 反馈表单
          FeedbackForm(
            key: _feedbackFormKey,
            onSubmit: _handleFeedbackSubmit,
            isLoading: _isSubmitting,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStageInfo(OrderStage stage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.work_outline,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stage.description.isNotEmpty ? stage.description : '请确认本阶段成果',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (stage.dueDate != null) ...[
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  '截止时间：${_formatDateTime(stage.dueDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(Order order) {
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
          // 联系手作人按钮
          Expanded(
            child: ButtonWidget(
              text: '联系手作人',
              isOutlined: true,
              onPressed: () async {
                final order = ref.read(orderProvider).currentOrder;
                if (order != null) {
                  final user = ref.read(authServiceProvider).currentUser;
                  if (user != null && order.artisanId != null) {
                    try {
                      final chatService = ref.read(chatServiceProvider);
                      final conversation = await chatService.getOrCreateConversation(
                        user.id,
                        order.artisanId!,
                        orderId: int.tryParse(order.id),
                      );
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              conversationId: conversation.id,
                              otherName: order.artisan?.name ?? '手作人',
                              otherAvatar: order.artisan?.avatar,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('创建会话失败: $e')),
                        );
                      }
                    }
                  }
                }
              },
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          // 提交确认按钮
          Expanded(
            child: ButtonWidget(
              text: _isSubmitting ? '提交中...' : '提交确认',
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _handleSubmit,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    // 触发表单验证和提交
    _feedbackFormKey.currentState?.submit();
  }

  void _handleFeedbackSubmit(FeedbackFormData formData) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final order = ref.read(orderProvider).currentOrder;
      if (order == null) return;

      final currentStage = order.currentStageDetail;
      if (currentStage == null) return;

      // 构建反馈参数
      final feedback = formData.type == FeedbackType.approve
          ? '确认通过${formData.content.isNotEmpty ? '：${formData.content}' : ''}'
          : formData.content;

      final success = await ref.read(orderProvider.notifier).confirmStageDelivery(
            widget.orderId,
            currentStage.id,
            feedback: feedback,
            images: formData.images.isNotEmpty ? formData.images : null,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                formData.type == FeedbackType.approve
                    ? '已确认通过'
                    : '已提交修改申请',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

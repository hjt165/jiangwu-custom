import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/business/rating_selector.dart';
import '../../widgets/business/tag_selector.dart';
import '../../widgets/business/image_picker_grid.dart';
import '../../widgets/common/async_data_view.dart';
import '../../widgets/common/button_widget.dart';
import '../../widgets/common/bottom_bar_widget.dart';

/// 评价页面
/// 用户对完成的订单进行评分和评价

class ReviewScreen extends ConsumerStatefulWidget {
  final String orderId;

  const ReviewScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  double _rating = 5;
  final TextEditingController _contentController = TextEditingController();
  List<String> _selectedTags = [];
  List<String> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderProvider.notifier).fetchOrderDetail(widget.orderId);
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('评价订单'),
      ),
      body: _buildBody(orderState),
      bottomNavigationBar: orderState.currentOrder != null
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildBody(OrderProvider orderState) {
    return AsyncDataView(
      isLoading: orderState.isLoading && orderState.currentOrder == null,
      error: orderState.currentOrder == null ? orderState.error : null,
      isEmpty: orderState.currentOrder == null,
      onRetry: () => ref.read(orderProvider.notifier).fetchOrderDetail(widget.orderId),
      emptyMessage: '订单不存在',
      builder: (context) {
    final order = orderState.currentOrder!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 订单信息摘要
          _buildOrderSummary(order),
          const SizedBox(height: AppSizes.paddingMedium),

          // 评分区域
          _buildRatingSection(),
          const SizedBox(height: AppSizes.paddingMedium),

          // 标签选择
          _buildTagSection(),
          const SizedBox(height: AppSizes.paddingMedium),

          // 评价内容
          _buildContentSection(),
          const SizedBox(height: AppSizes.paddingMedium),

          // 图片上传
          _buildImageSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
      },
    );
  }

  Widget _buildOrderSummary(Order order) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Row(
        children: [
          // 商品图片
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              color: AppColors.divider,
            ),
            child: order.product?.coverImage != null && order.product!.coverImage!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    child: Image.network(
                      order.product!.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_outlined,
                          color: AppColors.textHint,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.image_outlined,
                    color: AppColors.textHint,
                  ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.product?.title ?? '定制作品',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (order.artisan != null)
                  Text(
                    '手作人：${order.artisan!.name}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Column(
        children: [
          const Text(
            '请为本次定制体验打分',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          RatingSelector(
            rating: _rating,
            onRatingChanged: (rating) {
              setState(() {
                _rating = rating;
                // 切换评分时清空已选标签
                _selectedTags = [];
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTagSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppSizes.cardShadow,
      ),
      child: TagSelector(
        rating: _rating,
        selectedTags: _selectedTags,
        onTagsChanged: (tags) {
          setState(() {
            _selectedTags = tags;
          });
        },
      ),
    );
  }

  Widget _buildContentSection() {
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
          const Text(
            '评价内容',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          TextFormField(
            controller: _contentController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: '分享您的定制体验，帮助其他用户做出选择...',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
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
          const Text(
            '评价图片（选填，最多6张）',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          ImagePickerGrid(
            images: _selectedImages,
            maxImages: 6,
            enableDelete: true,
            onImagesChanged: (images) {
              setState(() {
                _selectedImages = images;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomBarContainer(
      child: ButtonWidget(
        text: _isSubmitting ? '提交中...' : '提交评价',
        isLoading: _isSubmitting,
        onPressed: _isSubmitting ? null : _handleSubmit,
      ),
    );
  }

  void _handleSubmit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await ref.read(orderProvider.notifier).submitReview(
            widget.orderId,
            rating: _rating,
            content: _contentController.text.trim(),
            images: _selectedImages.isNotEmpty ? _selectedImages : null,
            tags: _selectedTags.isNotEmpty ? _selectedTags : null,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('评价提交成功'),
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
}

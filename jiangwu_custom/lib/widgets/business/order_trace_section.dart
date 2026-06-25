import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../services/blockchain_service.dart';

/// 订单溯源存证区块
/// 展示区块链溯源记录列表

class OrderTraceSection extends StatelessWidget {
  final String orderId;

  const OrderTraceSection({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BlockchainRecord>>(
      future: BlockchainService().getRecords(orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final records = snapshot.data ?? [];

        return Container(
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
                    Icons.verified,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSizes.spacingSmall),
                  Text(
                    '溯源存证',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              if (records.isEmpty)
                const Text(
                  '暂无存证记录',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                )
              else
                ...records.map((record) => _buildTraceRecordItem(record)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTraceRecordItem(BlockchainRecord record) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: record.isVerified ? AppColors.success : AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getBlockchainTypeName(record.type),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (record.timestamp != null)
                  Text(
                    record.timestamp!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            record.isVerified ? Icons.check_circle : Icons.pending,
            size: 16,
            color: record.isVerified ? AppColors.success : AppColors.warning,
          ),
        ],
      ),
    );
  }

  String _getBlockchainTypeName(String type) {
    switch (type) {
      case 'order_created': return '订单创建';
      case 'order_signed': return '订单签订';
      case 'stage_delivered': return '阶段交付';
      case 'final_delivered': return '最终交付';
      case 'review_completed': return '评价完成';
      default: return type;
    }
  }
}

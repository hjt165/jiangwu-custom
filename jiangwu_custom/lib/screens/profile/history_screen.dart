import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../../providers/history_provider.dart';
import '../../widgets/business/artisan_works_grid.dart';
import '../../widgets/common/async_data_view.dart';

/// 浏览历史页
/// 通过 API 加载浏览历史

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(historyProvider.notifier).loadHistory();
    });
  }

  void _onProductTap(Product product) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetail,
      arguments: product.id,
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空历史'),
        content: const Text('确定要清空所有浏览历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(historyProvider.notifier).clearHistory();
              if (mounted) Navigator.of(context).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已清空浏览历史'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(
              '清空',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('浏览历史'),
        actions: [
          if (historyState.historyProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showClearHistoryDialog,
            ),
        ],
      ),
      body: AsyncDataView(
        isLoading: historyState.isLoading,
        error: historyState.error,
        isEmpty: historyState.historyProducts.isEmpty,
        onRetry: () => historyState.loadHistory(),
        emptyIcon: Icons.history,
        emptyMessage: '暂无浏览历史',
        builder: (context) => ArtisanWorksGrid(
          works: historyState.historyProducts,
          onWorkTap: _onProductTap,
        ),
      ),
    );
  }
}

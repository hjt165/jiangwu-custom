import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../../providers/artisan_product_provider.dart';
import '../../widgets/business/product_manage_card.dart';
import '../../widgets/common/async_data_view.dart';

/// 手作人作品管理页面

class ProductManageScreen extends ConsumerStatefulWidget {
  const ProductManageScreen({super.key});

  @override
  ConsumerState<ProductManageScreen> createState() => _ProductManageScreenState();
}

class _ProductManageScreenState extends ConsumerState<ProductManageScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(artisanProductProvider.notifier).fetchProducts(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(artisanProductProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('作品管理'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.publish);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _buildBody(productState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.publish);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildBody(ArtisanProductProvider productState) {
    return AsyncDataView(
      isLoading: productState.isLoading && productState.products.isEmpty,
      error: productState.products.isEmpty ? productState.error : null,
      isEmpty: productState.products.isEmpty,
      onRetry: () => ref.read(artisanProductProvider.notifier).fetchProducts(refresh: true),
      emptyMessage: '暂无作品，点击右下角按钮发布',
      builder: (context) => RefreshIndicator(
        onRefresh: () async {
          await ref.read(artisanProductProvider.notifier).fetchProducts(refresh: true);
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          itemCount: productState.products.length,
          itemBuilder: (context, index) {
            final product = productState.products[index];
            return ProductManageCard(
              product: product,
              onToggleStatus: () => _handleToggleStatus(product),
              onEdit: () {
                Navigator.pushNamed(context, AppRoutes.publish, arguments: product);
              },
              onDelete: () => _handleDeleteProduct(product),
            );
          },
        ),
      ),
    );
  }

  void _handleToggleStatus(Product product) {
    final action = product.isAvailable ? '下架' : '上架';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action作品'),
        content: Text('确定要$action「${product.title}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(artisanProductProvider.notifier)
                  .toggleProductStatus(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '已$action' : '操作失败'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除作品'),
        content: Text('确定要删除「${product.title}」吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(artisanProductProvider.notifier)
                  .deleteProduct(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '已删除' : '删除失败'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('确定删除'),
          ),
        ],
      ),
    );
  }
}
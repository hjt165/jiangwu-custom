import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

/// 作品详情页
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productProvider.notifier).fetchProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('作品详情'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppColors.error : null,
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              ref.read(favoritesProvider.notifier).toggleFavorite(widget.productId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: productState.isLoading
          ? const Center(child: LoadingWidget())
          : productState.error != null
              ? Center(child: CustomErrorWidget(message: productState.error!))
              : _buildContent(context, productState),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildContent(BuildContext context, ProductProvider state) {
    final product = state.currentProduct;
    if (product == null) {
      return const Center(child: Text('作品不存在'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片轮播
          _buildImageCarousel(product),

          // 作品信息
          _buildProductInfo(product),

          // 工艺参数
          _buildCraftParams(product),

          // 作品描述
          _buildDescription(product),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(Product product) {
    return SizedBox(
      height: 300,
      child: product.images.isEmpty
          ? Container(
              color: AppColors.divider,
              child: const Icon(Icons.image, size: 80, color: AppColors.textHint),
            )
          : PageView.builder(
              itemCount: product.images.length,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) {
                return Image.network(
                  product.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.divider,
                    child: const Icon(Icons.image, size: 80, color: AppColors.textHint),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.category.label,
                  style: const TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Row(
            children: [
              Text(
                '¥${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              if (product.hasDiscount) ...[
                const SizedBox(width: 8),
                Text(
                  '¥${product.originalPrice!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${product.discountPercent}%',
                    style: const TextStyle(fontSize: 12, color: AppColors.white),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Row(
            children: [
              _buildStatItem(Icons.star, '${product.rating}', AppColors.accent),
              const SizedBox(width: 16),
              _buildStatItem(Icons.visibility, '${product.viewCount}', AppColors.textSecondary),
              const SizedBox(width: 16),
              _buildStatItem(Icons.shopping_bag, '${product.orderCount}', AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 14, color: color)),
      ],
    );
  }

  Widget _buildCraftParams(Product product) {
    final params = product.craftParams;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '工艺参数',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          _buildParamRow('难度', params.difficulty),
          _buildParamRow('工期', '${params.estimatedDays}天'),
          _buildParamRow('材料费', '¥${params.materialCost.toStringAsFixed(0)}'),
          _buildParamRow('工时费', '¥${params.laborCost.toStringAsFixed(0)}'),
          if (params.technique.isNotEmpty) _buildParamRow('工艺', params.technique),
        ],
      ),
    );
  }

  Widget _buildParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDescription(Product product) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '作品描述',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          if (product.tags.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingMedium),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.chat,
                  arguments: {'otherName': '手作人'},
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('咨询手作人'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.publish,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('立即定制'),
            ),
          ),
        ],
      ),
    );
  }
}

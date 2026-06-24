import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/business/artisan_works_grid.dart';
import '../../widgets/common/async_data_view.dart';

/// 我的收藏页
/// 通过 API 加载收藏列表

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 加载收藏列表
    Future.microtask(() {
      ref.read(favoritesProvider.notifier).loadFavorites();
      ref.read(favoritesProvider.notifier).loadFavoriteArtisans();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: '作品'),
                Tab(text: '手作人'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(favoritesState),
                _buildArtisansTab(favoritesState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(FavoritesProvider state) {
    return AsyncDataView(
      isLoading: state.isLoading,
      error: state.error,
      isEmpty: state.favoriteProducts.isEmpty,
      onRetry: () => state.loadFavorites(),
      emptyIcon: Icons.favorite_border,
      emptyMessage: '暂无收藏作品',
      builder: (context) => ArtisanWorksGrid(
        works: state.favoriteProducts,
        onWorkTap: (product) {
          Navigator.of(context).pushNamed(
            AppRoutes.productDetail,
            arguments: product.id,
          );
        },
      ),
    );
  }

  Widget _buildArtisansTab(FavoritesProvider state) {
    return AsyncDataView(
      isLoading: state.isLoading,
      error: state.error,
      isEmpty: state.favoriteArtisans.isEmpty,
      onRetry: () => state.loadFavorites(),
      emptyIcon: Icons.people_outline,
      emptyMessage: '暂无收藏手作人',
      builder: (context) => ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: state.favoriteArtisans.length,
      itemBuilder: (context, index) {
        final artisan = state.favoriteArtisans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                (artisan['name'] ?? '手')[0],
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(artisan['name'] ?? '未知手作人'),
            subtitle: Text(artisan['specialty'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.warning),
                const SizedBox(width: 4),
                Text('${artisan['rating'] ?? '-'}'),
              ],
            ),
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.artisanProfile,
                arguments: (artisan['artisanId'] ?? '').toString(),
              );
            },
          ),
        );
      },
    ),
    );
  }
}

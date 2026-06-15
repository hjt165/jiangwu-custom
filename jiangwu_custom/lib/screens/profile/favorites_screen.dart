import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/business/artisan_works_grid.dart';
import '../../widgets/common/empty_widget.dart';

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
                _buildArtisansTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(FavoritesProvider state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(state.error!, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppSizes.spacingMedium),
            ElevatedButton(
              onPressed: () => state.loadFavorites(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (state.favoriteProducts.isEmpty) {
      return const EmptyWidget(
        icon: Icons.favorite_border,
        message: '暂无收藏作品',
      );
    }

    return ArtisanWorksGrid(
      works: state.favoriteProducts,
      onWorkTap: (product) {
        Navigator.of(context).pushNamed(
          '/product/${product.id}',
          arguments: product.id,
        );
      },
    );
  }

  Widget _buildArtisansTab() {
    // 后端暂无收藏手作人API，显示空状态
    return const EmptyWidget(
      icon: Icons.people_outline,
      message: '暂无收藏手作人',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../../models/artisan.dart';
import '../../providers/product_provider.dart';
import '../../providers/artisan_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/home/banner_widget.dart';
import '../../widgets/home/category_grid.dart';
import '../../widgets/home/product_card.dart';
import '../../widgets/home/artisan_card.dart';

/// 首页主页面
/// 推荐瀑布流、热门手作、手作人推荐

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 加载首页数据
    Future.microtask(() {
      ref.read(productProvider.notifier).fetchFeaturedProducts();
      ref.read(artisanProvider.notifier).fetchArtisans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final artisanState = ref.watch(artisanProvider);

    return RepaintBoundary(
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(productProvider.notifier).fetchFeaturedProducts();
          await ref.read(artisanProvider.notifier).fetchArtisans();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner轮播
              const HomeBanner(),

              // 分类入口
              CategoryGrid(
                onCategoryTap: (code, name) {
                  Navigator.of(context).pushNamed(
                    AppRoutes.category,
                    arguments: name,
                  );
                },
              ),

              // 热门推荐
              _buildHotSection(context, productState),

              // 手作人推荐
              _buildArtisanSection(context, artisanState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotSection(BuildContext context, ProductProvider productState) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '热门推荐',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.discover);
                },
                child: const Text('查看更多'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          SizedBox(
            height: 200,
            child: productState.isLoading && productState.featuredProducts.isEmpty
                ? const Center(child: LoadingWidget())
                : productState.error != null && productState.featuredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 32, color: AppColors.error),
                            const SizedBox(height: 8),
                            Text('加载失败: ${productState.error}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => ref.read(productProvider.notifier).fetchFeaturedProducts(),
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : productState.featuredProducts.isEmpty
                        ? const Center(child: Text('暂无推荐作品', style: TextStyle(color: AppColors.textHint)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: productState.featuredProducts.length,
                            itemBuilder: (context, index) {
                              final product = productState.featuredProducts[index];
                              return HomeProductCard(
                                product: product,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/product/',
                                    arguments: product.id,
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanSection(BuildContext context, ArtisanProvider artisanState) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '推荐手作人',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.discover);
                },
                child: const Text('查看更多'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          SizedBox(
            height: 120,
            child: artisanState.isLoading && artisanState.artisans.isEmpty
                ? const Center(child: LoadingWidget())
                : artisanState.error != null && artisanState.artisans.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 32, color: AppColors.error),
                            const SizedBox(height: 8),
                            Text('加载失败: ${artisanState.error}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => ref.read(artisanProvider.notifier).fetchArtisans(),
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : artisanState.artisans.isEmpty
                        ? const Center(child: Text('暂无推荐手作人', style: TextStyle(color: AppColors.textHint)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: artisanState.artisans.length,
                            itemBuilder: (context, index) {
                              final artisan = artisanState.artisans[index];
                              return HomeArtisanCard(
                                artisan: artisan,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.artisanProfile,
                                    arguments: artisan.id,
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
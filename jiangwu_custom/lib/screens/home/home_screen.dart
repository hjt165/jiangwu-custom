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

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.search);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
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
                  fontSize: 18,
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
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productState.featuredProducts.isEmpty
                        ? 5
                        : productState.featuredProducts.length,
                    itemBuilder: (context, index) {
                      if (productState.featuredProducts.isEmpty) {
                        return HomeProductCard(
                          onTap: null,
                        );
                      }
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
                  fontSize: 18,
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
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: artisanState.artisans.isEmpty
                        ? 4
                        : artisanState.artisans.length,
                    itemBuilder: (context, index) {
                      if (artisanState.artisans.isEmpty) {
                        return const HomeArtisanCard(
                          onTap: null,
                        );
                      }
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
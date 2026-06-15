import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../../models/artisan.dart';
import '../../providers/product_provider.dart';
import '../../providers/artisan_provider.dart';
import '../../widgets/common/loading_widget.dart';

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
              _buildBanner(),

              // 分类入口
              _buildCategorySection(context),

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

  Widget _buildBanner() {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 60,
              color: AppColors.white,
            ),
            SizedBox(height: AppSizes.spacingSmall),
            Text(
              '匠物定制',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: AppSizes.spacingXSmall),
            Text(
              AppStrings.appSlogan,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    final categories = [
      {'icon': Icons.checkroom, 'name': '首饰', 'code': 'jewelry'},
      {'icon': Icons.category, 'name': '皮具', 'code': 'leather'},
      {'icon': Icons.brush, 'name': '陶瓷', 'code': 'ceramic'},
      {'icon': Icons.texture, 'name': '木艺', 'code': 'woodwork'},
      {'icon': Icons.palette, 'name': '绘画', 'code': 'painting'},
      {'icon': Icons.more_horiz, 'name': '其他', 'code': 'other'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '工艺分类',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSizes.spacingMedium,
              crossAxisSpacing: AppSizes.spacingMedium,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.category,
                    arguments: category['name'],
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXSmall),
                    Text(
                      category['name'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
                  // TODO: 查看更多
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
                        return _buildProductCard(context, null);
                      }
                      return _buildProductCard(
                        context,
                        productState.featuredProducts[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product? product) {
    return GestureDetector(
      onTap: product != null
          ? () {
              Navigator.of(context).pushNamed(
                '/product/',
                arguments: product.id,
              );
            }
          : null,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: AppSizes.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: AppSizes.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 作品图片
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusMedium),
                ),
              ),
              child: product?.coverImage != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSizes.radiusMedium),
                      ),
                      child: Image.network(
                        product!.coverImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: AppColors.textHint,
                      ),
                    ),
            ),
            // 作品信息
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.title ?? '加载中...',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.spacingXSmall),
                  Text(
                    product != null ? '¥起' : '¥--',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                '手作人推荐',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 查看更多
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
                        ? 5
                        : artisanState.artisans.length,
                    itemBuilder: (context, index) {
                      if (artisanState.artisans.isEmpty) {
                        return _buildArtisanCard(context, null);
                      }
                      return _buildArtisanCard(
                        context,
                        artisanState.artisans[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanCard(BuildContext context, Artisan? artisan) {
    return GestureDetector(
      onTap: artisan != null
          ? () {
              Navigator.of(context).pushNamed(
                AppRoutes.artisanProfile,
                arguments: artisan.id,
              );
            }
          : null,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: AppSizes.spacingMedium),
        child: Column(
          children: [
            // 头像
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: artisan?.avatar != null
                  ? ClipOval(
                      child: Image.network(
                        artisan!.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.textHint,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.textHint,
                    ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            // 名称
            Text(
              artisan?.name ?? '加载中...',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.spacingXSmall),
            // 评分
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  size: 12,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 2),
                Text(
                  artisan != null ? artisan.rating.toStringAsFixed(1) : '--',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
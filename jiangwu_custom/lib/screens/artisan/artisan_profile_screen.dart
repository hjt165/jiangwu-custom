import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/artisan.dart';
import '../../models/review.dart';
import '../../providers/artisan_provider.dart';
import '../../widgets/business/artisan_header.dart';
import '../../widgets/business/artisan_works_grid.dart';
import '../../widgets/business/artisan_reviews_list.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/button_widget.dart';

/// 手作人主页
/// 展示手作人详情、作品列表、评价列表

class ArtisanProfileScreen extends ConsumerStatefulWidget {
  final String artisanId;

  const ArtisanProfileScreen({
    super.key,
    required this.artisanId,
  });

  @override
  ConsumerState<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends ConsumerState<ArtisanProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock评价数据（后续接入API）
  final List<Review> _mockReviews = [
    Review(
      id: '1',
      orderId: 'order_001',
      userId: 'user_001',
      userName: '小明',
      artisanId: 'artisan_001',
      artisanName: '手作人',
      rating: 5,
      content: '手作人非常专业，作品质量很好，细节处理得很到位！',
      tags: ['专业', '细致', '质量好'],
      images: [],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Review(
      id: '2',
      orderId: 'order_002',
      userId: 'user_002',
      userName: '小红',
      artisanId: 'artisan_001',
      artisanName: '手作人',
      rating: 4,
      content: '制作过程很用心，沟通也很顺畅，就是时间比预期长了一点。',
      tags: ['用心', '沟通顺畅', '稍慢'],
      images: [],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Review(
      id: '3',
      orderId: 'order_003',
      userId: 'user_003',
      userName: '小李',
      artisanId: 'artisan_001',
      artisanName: '手作人',
      rating: 5,
      content: '成品超出预期，非常满意！已经推荐给朋友了。',
      tags: ['超出预期', '推荐'],
      images: [],
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(artisanProvider.notifier).fetchArtisanDetail(widget.artisanId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artisanState = ref.watch(artisanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('手作人主页'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 分享功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: 更多操作
            },
          ),
        ],
      ),
      body: _buildBody(artisanState),
      bottomNavigationBar: artisanState.currentArtisan != null
          ? _buildBottomBar(artisanState.currentArtisan!)
          : null,
    );
  }

  Widget _buildBody(ArtisanProvider artisanState) {
    if (artisanState.isLoading && artisanState.currentArtisan == null) {
      return const LoadingWidget();
    }

    if (artisanState.error != null && artisanState.currentArtisan == null) {
      return CustomErrorWidget(
        message: artisanState.error!,
        onRetry: () {
          ref.read(artisanProvider.notifier).fetchArtisanDetail(widget.artisanId);
        },
      );
    }

    if (artisanState.currentArtisan == null) {
      return const Center(
        child: Text('手作人不存在', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final artisan = artisanState.currentArtisan!;

    return Column(
      children: [
        // 手作人信息头部
        ArtisanHeader(artisan: artisan),
        // TabBar
        Container(
          color: AppColors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: '作品'),
              Tab(text: '评价'),
            ],
          ),
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 作品网格
              ArtisanWorksGrid(
                works: artisan.works,
                onWorkTap: (product) {
                  // TODO: 跳转到作品详情或定制发布页
                  Navigator.of(context).pushNamed(
                    AppRoutes.publish,
                    arguments: {
                      'artisanId': artisan.id,
                      'productId': product.id,
                    },
                  );
                },
              ),
              // 评价列表
              ArtisanReviewsList(
                reviews: _mockReviews,
                averageRating: artisan.rating,
                totalReviews: artisan.ratingCount,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(Artisan artisan) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.paddingMedium,
        right: AppSizes.paddingMedium,
        top: AppSizes.paddingMedium,
        bottom: MediaQuery.of(context).padding.bottom + AppSizes.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 关注按钮
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: 关注/取消关注
              },
              icon: const Icon(Icons.favorite_border, size: 18),
              label: const Text('关注'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          // 预约定制按钮
          Expanded(
            flex: 2,
            child: ButtonWidget(
              text: '预约定制',
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.publish,
                  arguments: {'artisanId': artisan.id},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

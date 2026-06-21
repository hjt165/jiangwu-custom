import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/artisan.dart';
import '../../models/review.dart';
import '../../providers/artisan_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/business/artisan_header.dart';
import '../../widgets/business/artisan_works_grid.dart';
import '../../widgets/business/artisan_reviews_list.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/button_widget.dart';
import '../../utils/share_utils.dart';

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
  List<Review> _reviews = [];
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(artisanProvider.notifier).fetchArtisanDetail(widget.artisanId);
      _fetchReviews();
    });
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final response = await ApiService().get<List<dynamic>>(
        '/artisan/${widget.artisanId}/reviews',
      );
      setState(() {
        _reviews = response.map((e) => Review.fromJson(e)).toList();
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() => _isLoadingReviews = false);
    }
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
            onPressed: () => _handleShare(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreActions(),
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
              _isLoadingReviews
                  ? const Center(child: LoadingWidget())
                  : ArtisanReviewsList(
                      reviews: _reviews,
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
              onPressed: () => _handleFollow(artisan),
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

  void _handleShare() {
    final artisan = ref.read(artisanProvider).currentArtisan;
    if (artisan != null) {
      ShareUtils.shareArtisan(
        context,
        artisanId: widget.artisanId,
        artisanName: artisan.name ?? '手作人',
      );
    }
  }

  void _showMoreActions() {
    final artisan = ref.read(artisanProvider).currentArtisan;
    if (artisan == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('举报'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('拉黑'),
              onTap: () {
                Navigator.pop(context);
                _showBlockDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('举报手作人'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReportOption(ctx, '虚假信息'),
            _buildReportOption(ctx, '侵权内容'),
            _buildReportOption(ctx, '不当行为'),
            _buildReportOption(ctx, '其他原因'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(BuildContext ctx, String reason) {
    return ListTile(
      title: Text(reason),
      onTap: () {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已提交举报: $reason')),
        );
      },
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('拉黑手作人'),
        content: const Text('拉黑后将不再看到该手作人的作品和消息，确定要拉黑吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已拉黑该手作人')),
              );
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleFollow(Artisan artisan) async {
    try {
      final apiService = ApiService();
      await apiService.post<Map<String, dynamic>>(
        '/artisan/${artisan.id}/follow',
        fromJson: (data) => Map<String, dynamic>.from(data),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('关注成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('关注失败: $e')),
        );
      }
    }
  }
}

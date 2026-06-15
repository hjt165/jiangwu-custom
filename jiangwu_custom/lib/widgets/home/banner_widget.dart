import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 首页Banner轮播组件
/// 支持自动轮播和手动滑动

class HomeBanner extends StatefulWidget {
  final List<BannerItem>? items;
  final Function(BannerItem)? onTap;

  const HomeBanner({
    super.key,
    this.items,
    this.onTap,
  });

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final items = widget.items ?? [];
        if (items.isNotEmpty) {
          _currentIndex = (_currentIndex + 1) % items.length;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          _startAutoPlay();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items ?? [];

    if (items.isEmpty) {
      return _buildDefaultBanner();
    }

    return Container(
      height: 180,
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildBannerItem(items[index]);
              },
            ),
          ),
          if (items.length > 1)
            _buildIndicator(items.length),
        ],
      ),
    );
  }

  Widget _buildDefaultBanner() {
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

  Widget _buildBannerItem(BannerItem item) {
    return GestureDetector(
      onTap: widget.onTap != null ? () => widget.onTap!(item) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: item.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                child: Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _buildDefaultBanner(),
                ),
              )
            : _buildDefaultBanner(),
      ),
    );
  }

  Widget _buildIndicator(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.spacingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return Container(
            width: _currentIndex == index ? 16 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}

/// Banner数据项
class BannerItem {
  final String? imageUrl;
  final String? title;
  final String? linkUrl;
  final Map<String, dynamic>? extra;

  BannerItem({
    this.imageUrl,
    this.title,
    this.linkUrl,
    this.extra,
  });
}

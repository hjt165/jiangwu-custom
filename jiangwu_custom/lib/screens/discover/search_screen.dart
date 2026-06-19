import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/business/search_history_tags.dart';
import '../../widgets/business/filter_sort_sheet.dart';
import '../../widgets/business/artisan_works_grid.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/loading_widget.dart';

/// 搜索结果页
/// 展示搜索栏、搜索历史、热门搜索、筛选排序、搜索结果

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialKeyword;

  const SearchScreen({
    super.key,
    this.initialKeyword,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  String _keyword = '';
  FilterSortOptions _filterOptions = const FilterSortOptions();
  bool _hasSearched = false;

  // 热门搜索数据
  final List<String> _hotSearches = [
    '银饰',
    '皮包',
    '陶瓷花瓶',
    '木雕',
    '手工皂',
    '编织包',
  ];

  List<Product> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialKeyword ?? '');
    _focusNode = FocusNode();
    _keyword = widget.initialKeyword ?? '';

    if (_keyword.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(_keyword);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    setState(() {
      _keyword = keyword;
      _hasSearched = true;
      _isSearching = true;
    });

    // 保存搜索历史
    await _saveSearchHistory(keyword);

    // 调用真实搜索 API
    try {
      await ref.read(productProvider.notifier).searchProducts(keyword);
      final productState = ref.read(productProvider);
      _searchResults = productState.products;
      _applyFilter();
    } catch (e) {
      _searchResults = [];
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _searchResults = _searchResults.where((product) {
        // 分类筛选
        if (_filterOptions.category != null &&
            product.category != _filterOptions.category) {
          return false;
        }
        // 价格筛选
        if (_filterOptions.minPrice != null &&
            product.price < _filterOptions.minPrice!) {
          return false;
        }
        if (_filterOptions.maxPrice != null &&
            product.price > _filterOptions.maxPrice!) {
          return false;
        }
        return true;
      }).toList();

      // 排序
      switch (_filterOptions.sortType) {
        case SortType.priceAsc:
          _searchResults.sort((a, b) => a.price.compareTo(b.price));
          break;
        case SortType.priceDesc:
          _searchResults.sort((a, b) => b.price.compareTo(a.price));
          break;
        case SortType.sales:
          _searchResults.sort((a, b) => b.orderCount.compareTo(a.orderCount));
          break;
        case SortType.rating:
          _searchResults.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case SortType.newest:
          _searchResults.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
          break;
        case SortType.comprehensive:
          _searchResults.sort((a, b) {
            final scoreA = a.rating * 0.4 +
                a.orderCount * 0.3 +
                a.viewCount * 0.3;
            final scoreB = b.rating * 0.4 +
                b.orderCount * 0.3 +
                b.viewCount * 0.3;
            return scoreB.compareTo(scoreA);
          });
          break;
      }
    });
  }

  Future<void> _saveSearchHistory(String keyword) async {
    final storage = StorageService();
    await storage.init();
    final history = storage.getStringList('searchHistory');
    history.remove(keyword);
    history.insert(0, keyword);
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    await storage.setStringList('searchHistory', history);
  }

  void _showFilterSheet() {
    FilterSortSheet.show(
      context,
      currentOptions: _filterOptions,
      onConfirm: (options) {
        setState(() {
          _filterOptions = options;
        });
        _applyFilter();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _buildSearchBar(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.search,
            color: Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: '搜索手作作品、手作人...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
              onSubmitted: _performSearch,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _keyword = '';
                  _hasSearched = false;
                  _searchResults = [];
                });
              },
              child: Icon(
                Icons.close,
                color: Colors.white.withValues(alpha: 0.6),
                size: 16,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasSearched) {
      return _buildInitialContent();
    }

    if (_isSearching) {
      return const Center(child: LoadingWidget());
    }

    if (_searchResults.isEmpty) {
      return const EmptyWidget(
        icon: Icons.search_off,
        message: '未找到相关作品',
      );
    }

    return Column(
      children: [
        // 筛选标签栏
        _buildFilterBar(),
        // 搜索结果
        Expanded(
          child: ArtisanWorksGrid(
            works: _searchResults,
            onWorkTap: (product) {
              Navigator.of(context).pushNamed(
                '/product/${product.id}',
                arguments: product.id,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInitialContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索历史
          SearchHistoryTags(
            onTagTap: (tag) {
              _searchController.text = tag;
              _performSearch(tag);
            },
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          // 热门搜索
          _buildHotSearches(),
        ],
      ),
    );
  }

  Widget _buildHotSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.trending_up,
              size: 18,
              color: AppColors.error,
            ),
            SizedBox(width: AppSizes.spacingSmall),
            Text(
              '热门搜索',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Wrap(
          spacing: AppSizes.spacingSmall,
          runSpacing: AppSizes.spacingSmall,
          children: _hotSearches.map((tag) {
            return GestureDetector(
              onTap: () {
                _searchController.text = tag;
                _performSearch(tag);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      color: AppColors.white,
      child: Row(
        children: [
          // 当前筛选标签
          if (_filterOptions.category != null)
            Container(
              margin: const EdgeInsets.only(right: AppSizes.spacingSmall),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _filterOptions.category!.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _filterOptions = _filterOptions.copyWith(
                          clearCategory: true,
                        );
                      });
                      _applyFilter();
                    },
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          if (_filterOptions.minPrice != null || _filterOptions.maxPrice != null)
            Container(
              margin: const EdgeInsets.only(right: AppSizes.spacingSmall),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¥${_filterOptions.minPrice ?? 0}~${_filterOptions.maxPrice ?? "∞"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _filterOptions = _filterOptions.copyWith(
                          clearPrice: true,
                        );
                      });
                      _applyFilter();
                    },
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          // 结果数量
          Expanded(
            child: Text(
              '共${_searchResults.length}件作品',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ),
          // 排序按钮
          GestureDetector(
            onTap: _showFilterSheet,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _filterOptions.sortType.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

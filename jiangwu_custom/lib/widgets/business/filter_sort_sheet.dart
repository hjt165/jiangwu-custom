import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/product.dart';

/// 筛选排序选项
class FilterSortOptions {
  final ProductCategory? category;
  final double? minPrice;
  final double? maxPrice;
  final SortType sortType;

  const FilterSortOptions({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.sortType = SortType.comprehensive,
  });

  FilterSortOptions copyWith({
    ProductCategory? category,
    double? minPrice,
    double? maxPrice,
    SortType? sortType,
    bool clearCategory = false,
    bool clearPrice = false,
  }) {
    return FilterSortOptions(
      category: clearCategory ? null : (category ?? this.category),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      sortType: sortType ?? this.sortType,
    );
  }

  bool get hasFilter =>
      category != null || minPrice != null || maxPrice != null;
}

/// 排序类型枚举
enum SortType {
  comprehensive('综合'),
  priceAsc('价格升序'),
  priceDesc('价格降序'),
  sales('销量'),
  rating('评分'),
  newest('最新');

  final String label;
  const SortType(this.label);
}

/// 筛选排序底部弹窗
/// 支持分类、价格区间、排序方式筛选

class FilterSortSheet extends StatefulWidget {
  final FilterSortOptions currentOptions;
  final ValueChanged<FilterSortOptions> onConfirm;

  const FilterSortSheet({
    super.key,
    required this.currentOptions,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required FilterSortOptions currentOptions,
    required ValueChanged<FilterSortOptions> onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSortSheet(
        currentOptions: currentOptions,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet> {
  late ProductCategory? _selectedCategory;
  late SortType _selectedSortType;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentOptions.category;
    _selectedSortType = widget.currentOptions.sortType;
    _minPriceController = TextEditingController(
      text: widget.currentOptions.minPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.currentOptions.maxPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部指示条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '筛选排序',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedSortType = SortType.comprehensive;
                      _minPriceController.clear();
                      _maxPriceController.clear();
                    });
                  },
                  child: const Text(
                    '重置',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 内容区域
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 排序方式
                  _buildSectionTitle('排序方式'),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _buildSortTypeGrid(),
                  const SizedBox(height: AppSizes.paddingMedium),
                  // 分类筛选
                  _buildSectionTitle('作品分类'),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _buildCategoryGrid(),
                  const SizedBox(height: AppSizes.paddingMedium),
                  // 价格区间
                  _buildSectionTitle('价格区间'),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _buildPriceRange(),
                ],
              ),
            ),
          ),
          // 底部按钮
          Container(
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
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('确定'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSortTypeGrid() {
    return Wrap(
      spacing: AppSizes.spacingSmall,
      runSpacing: AppSizes.spacingSmall,
      children: SortType.values.map((type) {
        final isSelected = _selectedSortType == type;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSortType = type;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              type.label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: AppSizes.spacingSmall,
      runSpacing: AppSizes.spacingSmall,
      children: ProductCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = isSelected ? null : category;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              category.label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRange() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '最低价',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
              prefixText: '¥ ',
              prefixStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '~',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textHint,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '最高价',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
              prefixText: '¥ ',
              prefixStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleConfirm() {
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);

    final options = FilterSortOptions(
      category: _selectedCategory,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortType: _selectedSortType,
    );

    widget.onConfirm(options);
    Navigator.of(context).pop();
  }
}

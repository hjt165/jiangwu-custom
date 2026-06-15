import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../services/storage_service.dart';

/// 搜索历史标签组件
/// 展示搜索历史标签，支持删除、清空

class SearchHistoryTags extends StatefulWidget {
  final ValueChanged<String> onTagTap;
  final int maxTags;

  const SearchHistoryTags({
    super.key,
    required this.onTagTap,
    this.maxTags = 10,
  });

  @override
  State<SearchHistoryTags> createState() => _SearchHistoryTagsState();
}

class _SearchHistoryTagsState extends State<SearchHistoryTags> {
  List<String> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final storage = StorageService();
    await storage.init();
    final history = storage.getStringList('searchHistory');
    setState(() {
      _history = history.take(widget.maxTags).toList();
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    final storage = StorageService();
    await storage.init();
    await storage.remove('searchHistory');
    setState(() {
      _history = [];
    });
  }

  Future<void> _removeTag(String tag) async {
    final storage = StorageService();
    await storage.init();
    _history.remove(tag);
    await storage.setStringList('searchHistory', _history);
    setState(() {
      _history = _history.take(widget.maxTags).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.history,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppSizes.spacingSmall),
                Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('清空搜索历史'),
                    content: const Text('确定要清空所有搜索历史吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          _clearHistory();
                          Navigator.of(context).pop();
                        },
                        child: const Text('确定',
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                '清空',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Wrap(
          spacing: AppSizes.spacingSmall,
          runSpacing: AppSizes.spacingSmall,
          children: _history.map((tag) {
            return GestureDetector(
              onTap: () => widget.onTagTap(tag),
              onLongPress: () => _removeTag(tag),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

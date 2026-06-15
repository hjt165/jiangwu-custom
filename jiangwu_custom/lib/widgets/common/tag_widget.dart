import 'package:flutter/material.dart';
import '../app/constants.dart';

/// 标签组件
/// 提供标签展示、选择等功能

class TagWidget extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool isSelected;
  final VoidCallback? onTap;

  const TagWidget({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingSmall,
          vertical: AppSizes.spacingXSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (backgroundColor ?? AppColors.accent)
              : (backgroundColor ?? AppColors.background),
          borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isSelected
                ? (backgroundColor ?? AppColors.accent)
                : (textColor ?? AppColors.border),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? (textColor ?? AppColors.white)
                : (textColor ?? AppColors.textPrimary),
            fontSize: fontSize ?? 12,
          ),
        ),
      ),
    );
  }
}

/// 标签选择组件
class TagSelectWidget extends StatelessWidget {
  final List<String> tags;
  final List<String> selectedTags;
  final Function(List<String>) onSelectionChanged;
  final bool multiple;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final double spacing;
  final double runSpacing;

  const TagSelectWidget({
    super.key,
    required this.tags,
    this.selectedTags = const [],
    required this.onSelectionChanged,
    this.multiple = false,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.spacing = AppSizes.spacingSmall,
    this.runSpacing = AppSizes.spacingSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: tags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        return TagWidget(
          text: tag,
          backgroundColor: isSelected ? selectedColor : unselectedColor,
          textColor: isSelected ? selectedTextColor : unselectedTextColor,
          isSelected: isSelected,
          onTap: () {
            final newSelected = List<String>.from(selectedTags);
            if (multiple) {
              if (isSelected) {
                newSelected.remove(tag);
              } else {
                newSelected.add(tag);
              }
            } else {
              if (isSelected) {
                newSelected.clear();
              } else {
                newSelected.clear();
                newSelected.add(tag);
              }
            }
            onSelectionChanged(newSelected);
          },
        );
      }).toList(),
    );
  }
}

/// 标签输入组件
class TagInputWidget extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onTagsChanged;
  final String hintText;
  final int maxTags;
  final double spacing;
  final double runSpacing;

  const TagInputWidget({
    super.key,
    this.tags = const [],
    required this.onTagsChanged,
    this.hintText = '添加标签',
    this.maxTags = 10,
    this.spacing = AppSizes.spacingSmall,
    this.runSpacing = AppSizes.spacingSmall,
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  late List<String> _tags;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.tags);
  }

  @override
  void didUpdateWidget(covariant TagInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tags != widget.tags) {
      _tags = List.from(widget.tags);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isEmpty) return;
    if (_tags.length >= widget.maxTags) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多添加${widget.maxTags}个标签')),
      );
      return;
    }
    if (_tags.contains(tag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标签已存在')),
      );
      return;
    }
    setState(() {
      _tags.add(tag);
    });
    _controller.clear();
    widget.onTagsChanged(_tags);
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: widget.spacing,
            runSpacing: widget.runSpacing,
            children: _tags.map((tag) {
              return TagWidget(
                text: tag,
                isSelected: true,
                onTap: () => _removeTag(tag),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingSmall,
                    vertical: AppSizes.spacingXSmall,
                  ),
                ),
                onSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            IconButton(
              onPressed: () => _addTag(_controller.text),
              icon: const Icon(Icons.add_circle),
              color: AppColors.accent,
            ),
          ],
        ),
      ],
    );
  }
}

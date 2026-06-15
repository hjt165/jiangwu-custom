import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 收入统计图表组件
/// 展示收入趋势折线图（简化版，无第三方图表库）

class IncomeChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final String title;

  const IncomeChart({
    super.key,
    required this.data,
    required this.labels,
    this.title = '收入趋势',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          SizedBox(
            height: 160,
            child: data.isEmpty
                ? const Center(
                    child: Text(
                      '暂无数据',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 13,
                      ),
                    ),
                  )
                : CustomPaint(
                    size: const Size(double.infinity, 160),
                    painter: _ChartPainter(data: data),
                  ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          // 标签
          if (labels.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels.map((label) {
                return Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

/// 简易折线图绘制器
class _ChartPainter extends CustomPainter {
  final List<double> data;

  _ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final normalizedValue = range > 0 ? (data[i] - minVal) / range : 0.5;
      final y = size.height - (normalizedValue * size.height * 0.8) - size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // 填充区域
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // 折线
    canvas.drawPath(path, paint);

    // 绘制数据点
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final normalizedValue = range > 0 ? (data[i] - minVal) / range : 0.5;
      final y = size.height - (normalizedValue * size.height * 0.8) - size.height * 0.1;

      canvas.drawCircle(
        Offset(x, y),
        3,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

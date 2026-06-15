import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 3D预览页面
/// 展示定制作品的3D模型预览
/// TODO: 集成model_viewer_plus库实现真实3D渲染

class PreviewScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? params;

  const PreviewScreen({
    super.key,
    this.productId,
    this.params,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  double _rotationX = 0;
  double _rotationY = 0;
  double _scale = 1.0;
  bool _isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: const Text('3D预览'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () {
                    setState(() {
                      _isFullscreen = !_isFullscreen;
                    });
                  },
                ),
              ],
            ),
      body: Stack(
        children: [
          // 3D模型展示区域
          _build3DView(),

          // 底部控制栏
          if (!_isFullscreen) _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _build3DView() {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          _rotationY += details.focalPointDelta.dx * 0.01;
          _rotationX += details.focalPointDelta.dy * 0.01;
          _scale = (_scale * details.scale).clamp(0.5, 3.0);
        });
      },
      child: Container(
        color: AppColors.background,
        child: Center(
          child: Transform(
            transform: Matrix4.identity()
              ..rotateX(_rotationX)
              ..rotateY(_rotationY)
              ..setEntry(3, 2, 0.001)
              ..setEntry(0, 0, _scale)
              ..setEntry(1, 1, _scale)
              ..setEntry(2, 2, _scale),
            alignment: Alignment.center,
            child: _buildPlaceholderModel(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderModel() {
    // TODO: 替换为真实3D模型
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_in_ar,
            size: 80,
            color: AppColors.primary,
          ),
          SizedBox(height: AppSizes.spacingMedium),
          Text(
            '3D模型预览',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Text(
            '手势拖动旋转 · 双指缩放',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 旋转控制
              _buildRotationControls(),
              const SizedBox(height: AppSizes.spacingMedium),
              // 缩放控制
              _buildScaleControls(),
              const SizedBox(height: AppSizes.spacingMedium),
              // 操作按钮
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRotationControls() {
    return Row(
      children: [
        const Icon(Icons.rotate_right, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.spacingSmall),
        Expanded(
          child: Slider(
            value: _rotationY,
            min: -3.14,
            max: 3.14,
            onChanged: (value) {
              setState(() {
                _rotationY = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        const Icon(Icons.rotate_left, size: 20, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildScaleControls() {
    return Row(
      children: [
        const Icon(Icons.zoom_out, size: 20, color: AppColors.textSecondary),
        Expanded(
          child: Slider(
            value: _scale,
            min: 0.5,
            max: 3.0,
            onChanged: (value) {
              setState(() {
                _scale = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ),
        const Icon(Icons.zoom_in, size: 20, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetView,
            icon: const Icon(Icons.refresh),
            label: const Text('重置视角'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacingMedium),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: 确认定制方案
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            label: const Text('确认方案'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _resetView() {
    setState(() {
      _rotationX = 0;
      _rotationY = 0;
      _scale = 1.0;
    });
  }
}

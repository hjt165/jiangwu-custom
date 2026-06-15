import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 3D模型查看器组件
/// 展示glTF/VRM格式的3D模型
///
/// 注意：需要flutter_unity_widget包支持
/// 当前为占位实现，待Unity环境解封后接入

class ModelViewer extends StatefulWidget {
  final String? modelPath;
  final double? width;
  final double? height;
  final bool autoRotate;
  final bool showControls;

  const ModelViewer({
    super.key,
    this.modelPath,
    this.width,
    this.height,
    this.autoRotate = true,
    this.showControls = true,
  });

  @override
  State<ModelViewer> createState() => _ModelViewerState();
}

class _ModelViewerState extends State<ModelViewer> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    if (widget.modelPath == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: 接入flutter_unity_widget加载3D模型
      // final controller = UnityWidgetController();
      // await controller.loadModel(widget.modelPath!);

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '模型加载失败: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 300,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // 3D渲染区域（占位）
          Center(
            child: _buildPlaceholder(),
          ),

          // 加载指示器
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),

          // 错误提示
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // 控制按钮
          if (widget.showControls && !_isLoading && _error == null)
            Positioned(
              bottom: AppSizes.paddingMedium,
              right: AppSizes.paddingMedium,
              child: _buildControls(),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.view_in_ar,
          size: 64,
          color: AppColors.textHint.withOpacity(0.5),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        Text(
          '3D预览',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textHint.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Text(
          widget.modelPath ?? '未选择模型',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textHint.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        _buildControlButton(
          icon: Icons.rotate_right,
          onTap: () {
            // TODO: 旋转模型
          },
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        _buildControlButton(
          icon: Icons.zoom_in,
          onTap: () {
            // TODO: 放大模型
          },
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        _buildControlButton(
          icon: Icons.zoom_out,
          onTap: () {
            // TODO: 缩小模型
          },
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        _buildControlButton(
          icon: Icons.center_focus_strong,
          onTap: () {
            // TODO: 重置视角
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}

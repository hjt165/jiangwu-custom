# TFLite模型文件占位符

此目录用于存放TensorFlow Lite模型文件。

## 需要的模型文件：
- style_classifier.tflite - 风格分类模型
- color_extractor.tflite - 颜色提取模型
- object_detector.tflite - 物体检测模型

## 模型规格：
- 格式：TensorFlow Lite (.tflite)
- 量化：INT8量化（减小体积）
- 输入：224x224x3 RGB图像
- 输出：分类标签+置信度

## 获取方式：
1. 使用TensorFlow Lite Model Maker训练自定义模型
2. 从TensorFlow Hub下载预训练模型
3. 使用AI生成工具训练特定领域模型

## 注意事项：
1. 模型文件较大（约5-20MB）
2. 建议使用INT8量化减小体积
3. 确保模型输入尺寸与代码匹配
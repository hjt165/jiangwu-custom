import 'package:dio/dio.dart';
import 'api_service.dart';

/// 阿里云OSS上传服务
/// 提供文件直传、签名获取、进度回调等功能

class OSSService {
  static final OSSService _instance = OSSService._internal();
  factory OSSService() => _instance;
  OSSService._internal();

  final ApiService _apiService = ApiService();

  /// 获取OSS上传签名
  Future<OSSSignature> getSignature(String directory) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/oss/signature',
        queryParameters: {'directory': directory},
      );
      return OSSSignature.fromJson(response);
    } on DioException {
      rethrow;
    }
  }

  /// 上传文件到OSS（直传模式）
  /// [filePath] 本地文件路径
  /// [directory] OSS目录（如：images/products/）
  /// [onProgress] 上传进度回调 (sent, total)
  Future<OSSUploadResult> uploadFile({
    required String filePath,
    String directory = 'images/',
    ProgressCallback? onProgress,
  }) async {
    try {
      // 1. 获取签名
      final signature = await getSignature(directory);

      // 2. 构建文件名
      final ext = filePath.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}.$ext';
      final objectKey = '$directory$fileName';

      // 3. 直传到OSS
      final dio = Dio();
      final formData = FormData.fromMap({
        'key': objectKey,
        'policy': signature.policy,
        'OSSAccessKeyId': signature.accessKeyId,
        'signature': signature.signature,
        'success_action_status': '200',
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await dio.post(
        signature.uploadUrl,
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200) {
        final url = '${signature.bucketUrl}/$objectKey';
        return OSSUploadResult(
          success: true,
          url: url,
          objectKey: objectKey,
        );
      }

      return OSSUploadResult(
        success: false,
        errorMsg: '上传失败: HTTP ${response.statusCode}',
      );
    } catch (e) {
      return OSSUploadResult(
        success: false,
        errorMsg: '上传异常: $e',
      );
    }
  }

  /// 通过后端代理上传文件
  /// [filePath] 本地文件路径
  /// [directory] 上传目录
  /// [onProgress] 上传进度回调
  Future<OSSUploadResult> uploadViaProxy({
    required String filePath,
    String directory = 'images/',
    ProgressCallback? onProgress,
  }) async {
    try {
      final fileName = filePath.split('/').last;

      final formData = FormData.fromMap({
        'directory': directory,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiService.post<Map<String, dynamic>>(
        '/oss/upload',
        data: formData,
        onSendProgress: onProgress,
      );

      return OSSUploadResult(
        success: true,
        url: response['url'] ?? '',
        objectKey: response['objectKey'] ?? '',
      );
    } catch (e) {
      return OSSUploadResult(
        success: false,
        errorMsg: '上传失败: $e',
      );
    }
  }

  /// 批量上传文件
  /// [filePaths] 本地文件路径列表
  /// [directory] OSS目录
  /// [onProgress] 单个文件进度回调 (index, sent, total)
  Future<List<OSSUploadResult>> uploadBatch({
    required List<String> filePaths,
    String directory = 'images/',
    void Function(int index, int sent, int total)? onProgress,
  }) async {
    final results = <OSSUploadResult>[];

    for (int i = 0; i < filePaths.length; i++) {
      final result = await uploadFile(
        filePath: filePaths[i],
        directory: directory,
        onProgress: (sent, total) {
          onProgress?.call(i, sent, total);
        },
      );
      results.add(result);
    }

    return results;
  }

  /// 删除OSS文件
  Future<bool> deleteFile(String objectKey) async {
    try {
      await _apiService.delete<void>(
        '/oss/delete',
        queryParameters: {'objectKey': objectKey},
      );
      return true;
    } catch (e) {
      print('删除OSS文件失败: $e');
      return false;
    }
  }
}

/// OSS签名信息
class OSSSignature {
  final String uploadUrl;
  final String bucketUrl;
  final String accessKeyId;
  final String policy;
  final String signature;
  final String directory;

  OSSSignature({
    required this.uploadUrl,
    required this.bucketUrl,
    required this.accessKeyId,
    required this.policy,
    required this.signature,
    required this.directory,
  });

  factory OSSSignature.fromJson(Map<String, dynamic> json) {
    return OSSSignature(
      uploadUrl: json['uploadUrl'] ?? '',
      bucketUrl: json['bucketUrl'] ?? '',
      accessKeyId: json['accessKeyId'] ?? '',
      policy: json['policy'] ?? '',
      signature: json['signature'] ?? '',
      directory: json['directory'] ?? '',
    );
  }
}

/// OSS上传结果
class OSSUploadResult {
  final bool success;
  final String? url;
  final String? objectKey;
  final String? errorMsg;

  OSSUploadResult({
    required this.success,
    this.url,
    this.objectKey,
    this.errorMsg,
  });
}

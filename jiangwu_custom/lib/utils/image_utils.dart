import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  ImageUtils._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickFromCamera({int maxWidth = 1024, int maxHeight = 1024, int quality = 85}) async {
    final XFile? xfile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: quality,
    );
    return xfile != null ? File(xfile.path) : null;
  }

  static Future<File?> pickFromGallery({int maxWidth = 1024, int maxHeight = 1024, int quality = 85}) async {
    final XFile? xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: quality,
    );
    return xfile != null ? File(xfile.path) : null;
  }

  static Future<List<File>> pickMultiple({int maxImages = 9}) async {
    final List<XFile> xfiles = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    return xfiles.take(maxImages).map((x) => File(x.path)).toList();
  }

  static Future<File?> showPickDialog(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () async {
                Navigator.pop(ctx, await pickFromCamera());
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () async {
                Navigator.pop(ctx, await pickFromGallery());
              },
            ),
          ],
        ),
      ),
    );
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

import 'package:flutter/widgets.dart';
import 'platform_image_stub.dart'
    if (dart.library.io) 'platform_image_native.dart';

/// Platform-abstracted local image builder
/// On mobile: uses Image.file with dart:io
/// On web: returns empty widget (web should use network URLs)
Widget buildLocalImage(String path, {BoxFit fit = BoxFit.cover}) {
  return createLocalImage(path, fit: fit);
}

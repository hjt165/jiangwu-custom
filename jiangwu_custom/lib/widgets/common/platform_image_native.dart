import 'dart:io';
import 'package:flutter/widgets.dart';

/// Native implementation using Image.file
Widget createLocalImage(String path, {BoxFit fit = BoxFit.cover}) {
  return Image.file(
    File(path),
    fit: fit,
    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
  );
}

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  static Future<Uint8List> compressImage(XFile file) async {
    final bytes = await file.readAsBytes();
    if (kIsWeb) return bytes; // flutter_image_compress not supported on web
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 80,
      minWidth: 800,
      minHeight: 800,
    );
    return compressed;
  }
}

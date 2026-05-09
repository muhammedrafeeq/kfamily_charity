import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/image_utils.dart';
import 'supabase_service.dart';

class StorageService {
  final _storage = SupabaseService.client.storage;

  Future<String> uploadScreenshot({
    required XFile file,
    required int year,
    required int month,
    required String memberId,
  }) async {
    try {
      debugPrint('=== UPLOAD: compressing image...');
      final bytes = await ImageUtils.compressImage(file);
      debugPrint('=== UPLOAD: compressed to ${bytes.length} bytes');
      final path = '$year/$month/$memberId/${const Uuid().v4()}.jpg';
      debugPrint('=== UPLOAD: uploading to path=$path bucket=${SupabaseConstants.screenshotsBucket}');

      await _storage
          .from(SupabaseConstants.screenshotsBucket)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));

      debugPrint('=== UPLOAD: success');
      return path;
    } catch (e) {
      debugPrint('=== UPLOAD ERROR: $e');
      throw AppStorageException('Failed to upload screenshot: $e');
    }
  }

  Future<String> getSignedUrl(String path, {int expiresIn = 3600}) async {
    try {
      return await _storage
          .from(SupabaseConstants.screenshotsBucket)
          .createSignedUrl(path, expiresIn);
    } catch (e) {
      throw AppStorageException('Failed to get signed URL: $e');
    }
  }

  Future<void> deleteScreenshot(String path) async {
    try {
      await _storage.from(SupabaseConstants.screenshotsBucket).remove([path]);
    } catch (e) {
      throw AppStorageException('Failed to delete screenshot: $e');
    }
  }
}

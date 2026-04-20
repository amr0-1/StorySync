import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

const String kImageCacheKey = 'storysyncImageCache';

class CustomCacheManager {
  static const int maxCacheSize = 500 * 1024 * 1024;

  static final CacheManager _instance = CacheManager(
    Config(
      kImageCacheKey,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: kImageCacheKey),
      fileService: HttpFileService(),
    ),
  );

  static CacheManager get instance => _instance;

  static Future<void> clearCache() async {
    await _instance.emptyCache();
  }

  static Future<int> getCurrentCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (cacheDir == null) return 0;

      int totalSize = 0;
      final entities = cacheDir.listSync(recursive: true, followLinks: false);
      for (final entity in entities) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  static Future<Directory?> _getCacheDirectory() async {
    try {
      final defaultDir = await getTemporaryDirectory();
      final dir = Directory('${defaultDir.path}/$kImageCacheKey');
      if (await dir.exists()) {
        return dir;
      }
      return defaultDir;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> shouldCache() async {
    final currentSize = await getCurrentCacheSize();
    return currentSize < maxCacheSize;
  }
}

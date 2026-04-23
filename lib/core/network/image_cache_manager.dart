import 'package:flutter_cache_manager/flutter_cache_manager.dart';

const String kImageCacheKey = 'storysyncImageCache';

class CustomCacheManager {
  static const key = 'storysyncImageCache';

  static final CacheManager _instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 500,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  static CacheManager get instance => _instance;
}

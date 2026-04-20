import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storysync/core/network/image_cache_manager.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/shared/widgets/status_badge.dart';

/// List tile widget for displaying manga in list view
class MangaListTile extends StatelessWidget {
  /// The manga item to display
  final MangaItem manga;

  /// Callback when the tile is tapped
  final VoidCallback onTap;

  /// Callback when the quick increment (+1) action is triggered
  final VoidCallback onQuickIncrement;

  const MangaListTile({
    super.key,
    required this.manga,
    required this.onTap,
    required this.onQuickIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
        child: Row(
          children: [
            // Thumbnail wrapped in Hero
            Hero(
              tag: 'cover_${manga.mangaDexId}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                child: SizedBox(
                  width: AppDimensions.listThumbWidth,
                  height: AppDimensions.listThumbHeight,
                  child: _buildThumbnail(colors),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),

            // Title and info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    manga.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Status and author row
                  Row(
                    children: [
                      StatusBadge(status: manga.status, compact: true),
                      const SizedBox(width: 6),
                      if (manga.author != null)
                        Expanded(
                          child: Text(
                            manga.author!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Chapter counter
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${manga.currentChapter}',
                  style: AppTextStyles.monoMedium.copyWith(
                    color: colors.goldSpark,
                  ),
                ),
                if (manga.totalChapters != null)
                  Text(
                    '/ ${manga.totalChapters}',
                    style: AppTextStyles.monoSmall.copyWith(
                      color: colors.textHint,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(VoidInkColors colors) {
    if (manga.coverUrl != null && manga.coverUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: manga.coverUrl!,
        fit: BoxFit.cover,
        cacheManager: CustomCacheManager.instance,
        memCacheWidth: (AppDimensions.listThumbWidth * 2).toInt(),
        memCacheHeight: (AppDimensions.listThumbHeight * 2).toInt(),
        errorWidget: (context, url, error) => _buildPlaceholder(colors),
        progressIndicatorBuilder: (context, url, progress) {
          if (progress.progress == null) return _buildPlaceholder(colors);
          return _buildPlaceholder(colors, showLoading: true);
        },
      );
    }
    return _buildPlaceholder(colors);
  }

  Widget _buildPlaceholder(VoidInkColors colors, {bool showLoading = false}) {
    return Container(
      color: colors.inkPanel,
      child: Center(
        child: showLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
                ),
              )
            : Icon(
                Icons.image_not_supported_outlined,
                size: 20,
                color: colors.textHint,
              ),
      ),
    );
  }
}

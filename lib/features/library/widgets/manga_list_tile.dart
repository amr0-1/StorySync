import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storysync/core/models/reading_state.dart';
import 'package:storysync/core/network/image_cache_manager.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/shared/widgets/deep_press_card.dart';
import 'package:storysync/shared/widgets/reading_state_wrapper.dart';
import 'package:storysync/shared/widgets/status_badge.dart';
import 'package:storysync/features/library/presentation/controllers/debounced_chapter_controller.dart';

/// List tile widget for displaying manga in list view
class MangaListTile extends ConsumerWidget {
  /// The manga item to display
  final MangaItem manga;

  /// Callback when the tile is tapped
  final VoidCallback onTap;

  /// Callback when the quick increment (+1) action is triggered
  final VoidCallback onQuickIncrement;

  /// Behavioral reading state for ambient animation
  final ReadingState readingState;

  const MangaListTile({
    super.key,
    required this.manga,
    required this.onTap,
    required this.onQuickIncrement,
    this.readingState = ReadingState.normal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    // Read ephemeral offset for instant chapter display
    final offsets = ref.watch(chapterOffsetProvider);
    final offset = offsets[manga.mangaDexId] ?? 0;

    Widget tile = _buildTileContent(colors, offset);

    // Wrap in reading state wrapper for cold/hot animations
    if (readingState != ReadingState.normal) {
      tile = ReadingStateWrapper(
        state: readingState,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        child: tile,
      );
    }

    // Wrap in deep press for tap feedback
    return DeepPressCard(onTap: onTap, child: tile);
  }

  Widget _buildTileContent(VoidInkColors colors, int offset) {
    return Container(
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
                const SizedBox(height: AppDimensions.space4),
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

          // Chapter counter (uses ephemeral offset for instant feedback)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${manga.currentChapter + offset}',
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

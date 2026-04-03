import 'package:flutter/material.dart';
import 'package:mtrack/core/models/manga_item.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';
import 'package:mtrack/shared/widgets/status_badge.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
              child: SizedBox(
                width: AppDimensions.listThumbWidth,
                height: AppDimensions.listThumbHeight,
                child: _buildThumbnail(),
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
                    style: AppTextStyles.titleSmall,
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
                            style: AppTextStyles.bodySmall,
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
                    color: AppColors.goldSpark,
                  ),
                ),
                if (manga.totalChapters != null)
                  Text(
                    '/ ${manga.totalChapters}',
                    style: AppTextStyles.monoSmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (manga.coverUrl != null && manga.coverUrl!.isNotEmpty) {
      return Image.network(
        manga.coverUrl!,
        fit: BoxFit.cover,
        cacheWidth: (AppDimensions.listThumbWidth * 2).toInt(),
        cacheHeight: (AppDimensions.listThumbHeight * 2).toInt(),
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(showLoading: true);
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder({bool showLoading = false}) {
    return Container(
      color: AppColors.inkPanel,
      child: Center(
        child: showLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.goldSpark,
                  ),
                ),
              )
            : const Icon(
                Icons.menu_book_rounded,
                size: 20,
                color: AppColors.textHint,
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mtrack/core/models/manga_item.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';
import 'package:mtrack/shared/widgets/chapter_badge.dart';
import 'package:mtrack/shared/widgets/status_badge.dart';

/// Grid card widget for displaying manga in grid view
class MangaGridCard extends StatelessWidget {
  /// The manga item to display
  final MangaItem manga;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Callback when the +1 button is tapped
  final VoidCallback onQuickIncrement;

  const MangaGridCard({
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
        width: AppDimensions.gridCardWidth,
        decoration: BoxDecoration(
          color: AppColors.inkSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: AppColors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover image with overlays
            SizedBox(
              height: AppDimensions.gridCoverHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover image
                  _buildCoverImage(),

                  // Bottom scrim gradient
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: AppDimensions.gridCoverHeight * 0.4,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x99000000)],
                        ),
                      ),
                    ),
                  ),

                  // Chapter badge - bottom left
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: ChapterBadge(
                      current: manga.currentChapter,
                      total: manga.totalChapters,
                    ),
                  ),

                  // +1 button - bottom right
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onQuickIncrement,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.goldSpark,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXS,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '+1',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A0F00),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title and status
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        manga.title,
                        style: AppTextStyles.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Status badge
                    StatusBadge(status: manga.status, compact: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (manga.coverUrl != null && manga.coverUrl!.isNotEmpty) {
      return Image.network(
        manga.coverUrl!,
        fit: BoxFit.cover,
        cacheWidth: (AppDimensions.gridCardWidth * 2).toInt(),
        cacheHeight: (AppDimensions.gridCoverHeight * 2).toInt(),
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
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.goldSpark,
                  ),
                ),
              )
            : const Icon(
                Icons.menu_book_rounded,
                size: 40,
                color: AppColors.textHint,
              ),
      ),
    );
  }
}

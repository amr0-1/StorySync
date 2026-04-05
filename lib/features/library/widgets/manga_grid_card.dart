import 'package:flutter/material.dart';
import 'package:storysync/core/models/manga_item.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/shared/widgets/chapter_badge.dart';
import 'package:storysync/shared/widgets/status_badge.dart';

/// Grid card widget for displaying manga in grid view
class MangaGridCard extends StatefulWidget {
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
  State<MangaGridCard> createState() => _MangaGridCardState();
}

class _MangaGridCardState extends State<MangaGridCard> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: AppDimensions.gridCardWidth,
        decoration: BoxDecoration(
          color: colors.inkSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: colors.inkBorder,
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
                  // Cover image wrapped in Hero
                  Hero(
                    tag: 'cover_${widget.manga.id}',
                    child: _buildCoverImage(colors),
                  ),

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
                      current: widget.manga.currentChapter,
                      total: widget.manga.totalChapters,
                    ),
                  ),

                  // +1 button - bottom right with scale animation
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) => setState(() => _isButtonPressed = true),
                      onTapUp: (_) => setState(() => _isButtonPressed = false),
                      onTapCancel: () =>
                          setState(() => _isButtonPressed = false),
                      onTap: widget.onQuickIncrement,
                      child: AnimatedScale(
                        scale: _isButtonPressed ? 0.9 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _isButtonPressed
                                ? colors.goldDim
                                : colors.goldSpark,
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
                        widget.manga.title,
                        style: AppTextStyles.titleSmall.copyWith(color: colors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Status badge
                    StatusBadge(status: widget.manga.status, compact: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(VoidInkColors colors) {
    if (widget.manga.coverUrl != null && widget.manga.coverUrl!.isNotEmpty) {
      return Image.network(
        widget.manga.coverUrl!,
        fit: BoxFit.cover,
        cacheWidth: (AppDimensions.gridCardWidth * 2).toInt(),
        cacheHeight: (AppDimensions.gridCoverHeight * 2).toInt(),
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(colors),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
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
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
                ),
              )
            : Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: colors.textHint,
              ),
      ),
    );
  }
}

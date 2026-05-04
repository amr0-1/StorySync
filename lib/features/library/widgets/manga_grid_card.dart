import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storysync/core/models/reading_state.dart';
import 'package:storysync/core/network/image_cache_manager.dart';
import 'package:storysync/core/utils/haptic_util.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    as org_flutter_cache_manager;
import 'package:storysync/shared/widgets/chapter_badge.dart';
import 'package:storysync/shared/widgets/deep_press_card.dart';
import 'package:storysync/shared/widgets/reading_state_wrapper.dart';
import 'package:storysync/shared/widgets/status_badge.dart';

/// Grid card widget for displaying manga in grid view
class MangaGridCard extends StatefulWidget {
  /// The manga item to display
  final MangaItem manga;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Callback when the +1 button is tapped
  final VoidCallback onQuickIncrement;

  /// Behavioral reading state for ambient animation
  final ReadingState readingState;

  /// Whether to show the resume highlight glow
  final bool showResumeHighlight;

  const MangaGridCard({
    super.key,
    required this.manga,
    required this.onTap,
    required this.onQuickIncrement,
    this.readingState = ReadingState.normal,
    this.showResumeHighlight = false,
  });

  @override
  State<MangaGridCard> createState() => _MangaGridCardState();
}

class _MangaGridCardState extends State<MangaGridCard>
    with SingleTickerProviderStateMixin {
  bool _isButtonPressed = false;

  // Resume highlight animation
  AnimationController? _highlightController;
  Animation<double>? _highlightAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.showResumeHighlight) {
      _highlightController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      _highlightAnimation =
          TweenSequence<double>([
            TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.35), weight: 40),
            TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.0), weight: 60),
          ]).animate(
            CurvedAnimation(
              parent: _highlightController!,
              curve: Curves.easeInOut,
            ),
          );
      // Slight delay before triggering
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _highlightController?.forward();
      });
    }
  }

  @override
  void dispose() {
    _highlightController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    Widget card = _buildCardContent(colors);

    // Wrap in reading state wrapper for cold/hot animations
    if (widget.readingState != ReadingState.normal) {
      card = ReadingStateWrapper(
        state: widget.readingState,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: card,
      );
    }

    // Wrap in resume highlight if needed
    if (_highlightAnimation != null) {
      card = AnimatedBuilder(
        animation: _highlightAnimation!,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              boxShadow: [
                BoxShadow(
                  color: colors.goldDim.withValues(
                    alpha: _highlightAnimation!.value,
                  ),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          );
        },
        child: card,
      );
    }

    // Wrap in deep press for tap feedback
    return DeepPressCard(onTap: widget.onTap, child: card);
  }

  Widget _buildCardContent(VoidInkColors colors) {
    return Container(
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
                  tag: 'cover_${widget.manga.mangaDexId}',
                  child: _buildCoverImage(colors),
                ),

                // Bottom scrim gradient
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: AppDimensions.gridCoverHeight * 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          colors.inkVoid.withValues(alpha: 0.6),
                        ],
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
                    onTapCancel: () => setState(() => _isButtonPressed = false),
                    onTap: () {
                      StorySyncHaptics.lightTap();
                      widget.onQuickIncrement();
                    },
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
                        child: Center(
                          child: Text(
                            '+1',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.inkVoid,
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
                      style: AppTextStyles.titleSmall.copyWith(
                        color: colors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  // Status badge
                  StatusBadge(status: widget.manga.status, compact: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(VoidInkColors colors) {
    if (widget.manga.coverUrl != null && widget.manga.coverUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.manga.coverUrl!,
        fit: BoxFit.cover,
        cacheManager: CustomCacheManager.instance,
        memCacheWidth: (AppDimensions.gridCardWidth * 2).toInt(),
        memCacheHeight: (AppDimensions.gridCoverHeight * 2).toInt(),
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

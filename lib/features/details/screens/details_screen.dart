import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:storysync/core/models/manga_item.dart';
import 'package:storysync/core/models/reading_status.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/shared/widgets/chapter_stepper.dart';
import 'package:storysync/shared/widgets/status_badge.dart';

/// Manga details screen with hero header and tracker console
class DetailsScreen extends StatefulWidget {
  /// The manga ID to display
  final String mangaId;

  const DetailsScreen({super.key, required this.mangaId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // Demo data - replace with actual Isar lookup
  late MangaItem _manga;
  late int _currentChapter;
  late ReadingStatus _status;

  @override
  void initState() {
    super.initState();
    // Load demo data based on mangaId
    _manga = _getDemoManga(widget.mangaId);
    _currentChapter = _manga.currentChapter;
    _status = _manga.status;
  }

  MangaItem _getDemoManga(String id) {
    // Demo manga data
    return const MangaItem(
      id: '1',
      title: 'Solo Leveling',
      author: 'Chugong',
      coverUrl:
          'https://uploads.mangadex.org/covers/32d76d19-8a05-4db0-9fc2-e0b0648fe9d0/e90bdc47-c8b9-4df7-b2c0-17641b645ee1.jpg',
      synopsis:
          'In a world where hunters — humans who possess magical abilities — must battle deadly monsters to protect the human race from certain annihilation, a notoriously weak hunter named Sung Jinwoo finds himself in a seemingly endless struggle for survival. One day, after narrowly surviving an overwhelmingly powerful double dungeon that nearly wipes out his entire party, a mysterious program called the System chooses him as its sole player and in turn, gives him the extremely rare potential of unlimited growth. With his new found power, Jinwoo grows rapidly and soon becomes the strongest hunter in the world.',
      demographic: 'Seinen',
      publicationStatus: 'Finished',
      status: ReadingStatus.reading,
      currentChapter: 134,
      totalChapters: 179,
    );
  }

  @override
  Widget build(BuildContext context) {
    final VoidInkColors colors = Theme.of(context).extension<VoidInkColors>()!;

    return Scaffold(
      backgroundColor: colors.inkVoid,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: _HeroHeader(manga: _manga, colors: colors),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info block
                _InfoBlock(manga: _manga, status: _status, colors: colors),
                const SizedBox(height: AppDimensions.space24),

                // Synopsis
                _Synopsis(synopsis: _manga.synopsis, colors: colors),
                const SizedBox(height: AppDimensions.space24),

                // Tracker console
                _TrackerConsole(
                  manga: _manga,
                  status: _status,
                  currentChapter: _currentChapter,
                  colors: colors,
                  onStatusChanged: (status) {
                    setState(() {
                      _status = status;
                    });
                  },
                  onChapterChanged: (chapter) {
                    setState(() {
                      _currentChapter = chapter;
                    });
                  },
                ),
                const SizedBox(height: AppDimensions.space32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final MangaItem manga;
  final VoidInkColors colors;

  const _HeroHeader({
    required this.manga,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.36;

    return SizedBox(
      height: headerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background
          if (manga.coverUrl != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0x99000000),
                  BlendMode.darken,
                ),
                child: Image.network(
                  manga.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: colors.inkPanel),
                ),
              ),
            )
          else
            Container(color: colors.inkPanel),

          // Bottom gradient — uses inkVoid so it blends into scaffold
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: headerHeight * 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colors.inkVoid.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          // Cover image centered - Hero animation target
          Center(
            child: Hero(
              tag: 'cover_${manga.id}',
              child: Container(
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  child: manga.coverUrl != null
                      ? Image.network(
                          manga.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _CoverPlaceholder(colors: colors),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _CoverPlaceholder(colors: colors, showLoading: true);
                          },
                        )
                      : _CoverPlaceholder(colors: colors),
                ),
              ),
            ),
          ),

          // Title at bottom left
          Positioned(
            left: AppDimensions.space16,
            right: AppDimensions.space16,
            bottom: AppDimensions.space16,
            child: Text(
              manga.title,
              style: AppTextStyles.displayLarge.copyWith(
                color: colors.goldLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  final VoidInkColors colors;
  final bool showLoading;

  const _CoverPlaceholder({
    required this.colors,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 180,
      color: colors.inkPanel,
      child: Center(
        child: showLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.goldSpark,
                  ),
                ),
              )
            : Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: colors.textHint,
              ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final MangaItem manga;
  final ReadingStatus status;
  final VoidInkColors colors;

  const _InfoBlock({
    required this.manga,
    required this.status,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author row
        Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: colors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.space8),
            Text(
              manga.author ?? 'Unknown',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),

        // Status row
        Row(
          children: [
            StatusBadge(status: status),
            const SizedBox(width: AppDimensions.space12),
            if (manga.demographic != null)
              Text(
                manga.demographic!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Synopsis extends StatefulWidget {
  final String? synopsis;
  final VoidInkColors colors;

  const _Synopsis({
    required this.synopsis,
    required this.colors,
  });

  @override
  State<_Synopsis> createState() => _SynopsisState();
}

class _SynopsisState extends State<_Synopsis> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final String? syn = widget.synopsis;
    if (syn == null || syn.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SYNOPSIS',
          style: AppTextStyles.overline.copyWith(color: widget.colors.textHint),
        ),
        const SizedBox(height: AppDimensions.space8),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            syn,
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.colors.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            syn,
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.space4),
        TextButton(
          onPressed: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _expanded ? 'Show less' : 'Read more',
            style: AppTextStyles.bodySmall.copyWith(color: widget.colors.goldSpark),
          ),
        ),
      ],
    );
  }
}

class _TrackerConsole extends StatelessWidget {
  final MangaItem manga;
  final ReadingStatus status;
  final int currentChapter;
  final VoidInkColors colors;
  final ValueChanged<ReadingStatus> onStatusChanged;
  final ValueChanged<int> onChapterChanged;

  const _TrackerConsole({
    required this.manga,
    required this.status,
    required this.currentChapter,
    required this.colors,
    required this.onStatusChanged,
    required this.onChapterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: colors.inkPanel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status dropdown
          Text(
            'STATUS',
            style: AppTextStyles.overline.copyWith(color: colors.textHint),
          ),
          const SizedBox(height: AppDimensions.space8),
          _StatusDropdown(
            status: status,
            colors: colors,
            onChanged: onStatusChanged,
          ),
          const SizedBox(height: AppDimensions.space24),

          // Chapter stepper
          ChapterStepper(
            currentChapter: currentChapter,
            totalChapters: manga.totalChapters,
            onChanged: onChapterChanged,
          ),
        ],
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final ReadingStatus status;
  final VoidInkColors colors;
  final ValueChanged<ReadingStatus> onChanged;

  const _StatusDropdown({
    required this.status,
    required this.colors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space8,
      ),
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: DropdownButton<ReadingStatus>(
        value: status,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: colors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: colors.textSecondary,
        ),
        selectedItemBuilder: (context) {
          return ReadingStatus.values.map((s) {
            return Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(status: s),
            );
          }).toList();
        },
        items: ReadingStatus.values.map((s) {
          return DropdownMenuItem<ReadingStatus>(
            value: s,
            child: Row(
              children: [
                StatusBadge(status: s, compact: true),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  s.displayLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mtrack/core/models/manga_item.dart';
import 'package:mtrack/core/models/reading_status.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';
import 'package:mtrack/shared/widgets/chapter_stepper.dart';
import 'package:mtrack/shared/widgets/status_badge.dart';

/// Manga details screen with hero header and tracker console
class DetailsScreen extends StatefulWidget {
  /// The manga ID to display
  final String mangaId;

  const DetailsScreen({super.key, required this.mangaId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _synopsisExpanded = false;

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
    return Scaffold(
      backgroundColor: AppColors.inkVoid,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(child: _buildHeroHeader(context)),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info block
                _buildInfoBlock(),
                const SizedBox(height: AppDimensions.space24),

                // Synopsis
                _buildSynopsis(),
                const SizedBox(height: AppDimensions.space24),

                // Tracker console
                _buildTrackerConsole(),
                const SizedBox(height: AppDimensions.space32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final headerHeight = MediaQuery.of(context).size.height * 0.36;

    return SizedBox(
      height: headerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background
          if (_manga.coverUrl != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0x99000000),
                  BlendMode.darken,
                ),
                child: Image.network(
                  _manga.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.inkPanel),
                ),
              ),
            )
          else
            Container(color: AppColors.inkPanel),

          // Bottom gradient
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: headerHeight * 0.5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC08080A)],
                ),
              ),
            ),
          ),

          // Cover image centered
          Center(
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
                child: _manga.coverUrl != null
                    ? Image.network(
                        _manga.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildCoverPlaceholder(),
                      )
                    : _buildCoverPlaceholder(),
              ),
            ),
          ),

          // Title at bottom left
          Positioned(
            left: AppDimensions.space16,
            right: AppDimensions.space16,
            bottom: AppDimensions.space16,
            child: Text(
              _manga.title,
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.goldLight,
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
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      width: 130,
      height: 180,
      color: AppColors.inkPanel,
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 48,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildInfoBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author row
        Row(
          children: [
            const Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.space8),
            Text(_manga.author ?? 'Unknown', style: AppTextStyles.bodyMedium),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),

        // Status row
        Row(
          children: [
            StatusBadge(status: _status),
            const SizedBox(width: AppDimensions.space12),
            if (_manga.demographic != null)
              Text(_manga.demographic!, style: AppTextStyles.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildSynopsis() {
    if (_manga.synopsis == null || _manga.synopsis!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SYNOPSIS', style: AppTextStyles.overline),
        const SizedBox(height: AppDimensions.space8),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _synopsisExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            _manga.synopsis!,
            style: AppTextStyles.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(_manga.synopsis!, style: AppTextStyles.bodyMedium),
        ),
        const SizedBox(height: AppDimensions.space4),
        TextButton(
          onPressed: () {
            setState(() {
              _synopsisExpanded = !_synopsisExpanded;
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _synopsisExpanded ? 'Show less' : 'Read more',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldSpark),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackerConsole() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.inkPanel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: AppColors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status dropdown
          Text('STATUS', style: AppTextStyles.overline),
          const SizedBox(height: AppDimensions.space8),
          _buildStatusDropdown(),
          const SizedBox(height: AppDimensions.space24),

          // Chapter stepper
          ChapterStepper(
            currentChapter: _currentChapter,
            totalChapters: _manga.totalChapters,
            onChanged: (value) {
              setState(() {
                _currentChapter = value;
              });
              // TODO: Update Isar
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: AppColors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: DropdownButton<ReadingStatus>(
        value: _status,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.inkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
        ),
        selectedItemBuilder: (context) {
          return ReadingStatus.values.map((status) {
            return Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(status: status),
            );
          }).toList();
        },
        items: ReadingStatus.values.map((status) {
          return DropdownMenuItem<ReadingStatus>(
            value: status,
            child: Row(
              children: [
                StatusBadge(status: status, compact: true),
                const SizedBox(width: AppDimensions.space8),
                Text(status.displayLabel, style: AppTextStyles.bodyMedium),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _status = value;
            });
            // TODO: Update Isar
          }
        },
      ),
    );
  }
}

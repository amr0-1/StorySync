import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:storysync/core/network/image_cache_manager.dart';
import 'package:storysync/features/discover/presentation/controllers/discover_controller.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/presentation/controllers/library_controller.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/core/utils/snackbar_util.dart';
import 'package:storysync/shared/widgets/chapter_stepper.dart';
import 'package:storysync/shared/widgets/status_badge.dart';
import 'package:storysync/shared/widgets/edit_manga_dialog.dart';
import 'package:storysync/features/details/presentation/controllers/palette_controller.dart';
import 'package:storysync/core/utils/haptic_util.dart';

/// Manga details screen with hero header and tracker console
class DetailsScreen extends ConsumerStatefulWidget {
  /// The manga ID to display (MangaDex UUID)
  final String mangaId;

  const DetailsScreen({super.key, required this.mangaId});

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  MangaItem? _manga;
  bool _isLoading = true;
  bool _isInLibrary = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Defer loading so the route transition animation plays smoothly
    // before heavy Isar queries block the main thread.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadManga();
    });
  }

  Future<void> _loadManga() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First check if it's in the library
      final libraryManga = await ref
          .read(libraryControllerProvider.notifier)
          .getManga(widget.mangaId);

      if (libraryManga != null) {
        setState(() {
          _manga = libraryManga;
          _isInLibrary = true;
          _isLoading = false;
        });
        return;
      }

      // If not in library, fetch from MangaDex
      final mangaDexManga = await ref
          .read(discoverControllerProvider.notifier)
          .getMangaDetails(widget.mangaId);

      setState(() {
        _manga = mangaDexManga;
        _isInLibrary = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final VoidInkColors colors = Theme.of(context).extension<VoidInkColors>()!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.inkVoid,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
          ),
        ),
      );
    }

    if (_error != null || _manga == null) {
      return Scaffold(
        backgroundColor: colors.inkVoid,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: colors.textHint,
              ),
              const SizedBox(height: AppDimensions.space16),
              Text(
                'Failed to load manga',
                style: AppTextStyles.titleMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                _error ?? 'Unknown error',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space16),
              TextButton(
                onPressed: _loadManga,
                child: Text(
                  'Retry',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.goldSpark,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final watchedManga = _isInLibrary
        ? ref.watch(mangaByIdProvider(widget.mangaId)).value
        : null;
    final manga = watchedManga ?? _manga!;

    final String paletteKey = '${manga.mangaDexId}|${manga.coverUrl}';
    final AsyncValue<Color?> paletteColor = ref.watch(
      coverPaletteProvider(paletteKey),
    );

    return Scaffold(
      backgroundColor: colors.inkVoid,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: _HeroHeader(
              manga: manga,
              colors: colors,
              paletteColor: paletteColor,
              onEdit: () => _showEditDialog(manga),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info block
                _InfoBlock(
                  manga: manga,
                  status: manga.readingStatus,
                  colors: colors,
                ),
                const SizedBox(height: AppDimensions.space24),

                // Synopsis
                _Synopsis(synopsis: manga.synopsis, colors: colors),
                const SizedBox(height: AppDimensions.space24),

                // Add to Library button (if not in library)
                if (!_isInLibrary) ...[
                  _AddToLibraryButton(
                    colors: colors,
                    onPressed: () => _addToLibrary(manga),
                  ),
                  const SizedBox(height: AppDimensions.space24),
                ],

                // Tracker console (if in library)
                if (_isInLibrary)
                  _TrackerConsole(
                    manga: manga,
                    colors: colors,
                    onStatusChanged: (status) => _updateStatus(manga, status),
                    onChapterChanged: (chapter) =>
                        _updateChapter(manga, chapter),
                  ),

                if (_isInLibrary) ...[
                  const SizedBox(height: AppDimensions.space24),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _handleDelete(manga),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        'Remove from Library',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.space32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles the delete action with a cascading-delete guard.
  ///
  /// If reading logs exist for this title, presents a guard dialog
  /// offering "Move to Dropped" or "Force Delete". If no logs exist,
  /// executes a simple delete immediately.
  Future<void> _handleDelete(MangaItem manga) async {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final controller = ref.read(libraryControllerProvider.notifier);

    // Check for orphaned reading logs
    final logCount = await controller.getReadingLogCount(manga.mangaDexId);

    if (!mounted) return;

    if (logCount > 0) {
      // Show guard dialog with two options
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.inkSurface,
          title: Text(
            'Reading History Found',
            style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
          ),
          content: Text(
            'This title has $logCount reading log${logCount == 1 ? '' : 's'}. '
            'Would you prefer to move it to your "Dropped" list to '
            'preserve your Insights, or permanently delete all data?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => ctx.pop('dropped'),
              child: Text(
                'Move to Dropped',
                style: AppTextStyles.labelMedium.copyWith(
                  color: colors.goldSpark,
                ),
              ),
            ),
            TextButton(
              onPressed: () => ctx.pop('force'),
              child: Text(
                'Force Delete',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      );

      if (!mounted || action == null) return;

      if (action == 'dropped') {
        final success = await controller.moveToDropped(manga.mangaDexId);
        if (mounted) {
          if (success) {
            setState(() => _isInLibrary = true);
            _refreshMangaData();
            VoidInkSnackbar.showSuccess(
              context,
              'Moved to Dropped — Insights preserved',
            );
          } else {
            VoidInkSnackbar.showError(context, 'Failed to update status');
          }
        }
      } else if (action == 'force') {
        final deleted = await controller.forceDeleteWithLogs(manga.mangaDexId);
        if (mounted) {
          if (deleted) {
            setState(() => _isInLibrary = false);
            context.pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                VoidInkSnackbar.showSuccess(
                  context,
                  'Deleted with all reading history',
                );
              }
            });
          } else {
            VoidInkSnackbar.showError(context, 'Failed to delete');
          }
        }
      }
    } else {
      // No logs — use the simple delete confirmation
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.inkSurface,
          title: Text(
            'Remove from Library',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to remove "${manga.title}" from your library?',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(false),
              child: Text('Cancel', style: TextStyle(color: colors.textHint)),
            ),
            TextButton(
              onPressed: () => ctx.pop(true),
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        _removeFromLibrary(manga);
      }
    }
  }

  Future<void> _addToLibrary(MangaItem manga) async {
    await ref.read(libraryControllerProvider.notifier).addManga(manga);

    if (mounted) {
      setState(() {
        _isInLibrary = true;
      });
      VoidInkSnackbar.showSuccess(context, 'Added to Library');
      // Reload to get the library version
      _loadManga();
    }
  }

  Future<void> _removeFromLibrary(MangaItem manga) async {
    final removed = await ref
        .read(libraryControllerProvider.notifier)
        .removeManga(manga.mangaDexId);

    if (mounted) {
      if (removed) {
        setState(() {
          _isInLibrary = false;
        });
        context.pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            VoidInkSnackbar.showSuccess(context, 'Removed from Library');
          }
        });
      } else {
        context.pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            VoidInkSnackbar.showError(context, 'Failed to remove from library');
          }
        });
      }
    }
  }

  Future<void> _updateStatus(MangaItem manga, ReadingStatus status) async {
    final success = await ref
        .read(libraryControllerProvider.notifier)
        .updateStatus(manga.mangaDexId, status);

    if (mounted) {
      if (success) {
        VoidInkSnackbar.showSuccess(context, 'Status updated');
        _refreshMangaData();
      } else {
        VoidInkSnackbar.showError(context, 'Failed to update status');
      }
    }
  }

  /// Refreshes manga data without showing loading spinner
  Future<void> _refreshMangaData() async {
    try {
      final updatedManga = await ref
          .read(libraryControllerProvider.notifier)
          .getManga(widget.mangaId);

      if (mounted && updatedManga != null) {
        setState(() {
          _manga = updatedManga;
        });
      }
    } catch (e) {
      // Silently fail - the UI already shows the previous state
    }
  }

  /// Updates chapter progress
  Future<void> _updateChapter(MangaItem manga, int newChapter) async {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final currentChapter = manga.chapterProgress;

    if (newChapter > currentChapter) {
      final accepted = await ref
          .read(libraryControllerProvider.notifier)
          .incrementChapter(manga.mangaDexId);

      if (!accepted && mounted) {
        final todayCount = await ref
            .read(libraryControllerProvider.notifier)
            .getTodayChapterCount(manga.mangaDexId);

        if (!mounted) return;

        if (todayCount >= 50) {
          final isPastReading = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: colors.inkSurface,
              title: Text(
                'Whoa, that\'s a lot!',
                style: AppTextStyles.titleLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              content: Text(
                'Are you adding past reading history, or is this your current pace?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => ctx.pop(true),
                  child: Text(
                    'Past Reading',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => ctx.pop(false),
                  child: Text(
                    'Current Pace',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: colors.goldSpark,
                    ),
                  ),
                ),
              ],
            ),
          );

          if (isPastReading != null && mounted) {
            await ref
                .read(libraryControllerProvider.notifier)
                .confirmAndIncrementChapter(manga.mangaDexId, isPastReading);
          }
        } else {
          VoidInkSnackbar.showError(context, 'Already at max chapters');
        }
      }
    } else if (newChapter < currentChapter) {
      // Decrementing — direct call (not a rapid-tap scenario)
      final success = await ref
          .read(libraryControllerProvider.notifier)
          .decrementChapter(manga.mangaDexId);

      if (mounted) {
        if (!success) {
          VoidInkSnackbar.showError(context, 'Already at 0 chapters');
        }
      }
    }
  }

  void _showEditDialog(MangaItem manga) {
    showDialog(
      context: context,
      builder: (ctx) => EditMangaDialog(
        manga: manga,
        onSave: (updatedManga) async {
          if (_isInLibrary) {
            // If in library, update in the database
            await ref
                .read(libraryControllerProvider.notifier)
                .updateManga(updatedManga);
            if (mounted) {
              VoidInkSnackbar.showSuccess(context, 'Manga updated');
              _loadManga();
            }
          } else {
            // If not in library, just update local state
            setState(() {
              _manga = updatedManga;
            });
            if (mounted) {
              VoidInkSnackbar.showSuccess(context, 'Changes saved locally');
            }
          }
        },
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final MangaItem manga;
  final VoidInkColors colors;
  final AsyncValue<Color?> paletteColor;
  final VoidCallback onEdit;

  const _HeroHeader({
    required this.manga,
    required this.colors,
    required this.paletteColor,
    required this.onEdit,
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
                colorFilter: ColorFilter.mode(
                  colors.inkVoid.withValues(alpha: 0.6),
                  BlendMode.darken,
                ),
                child: CachedNetworkImage(
                  imageUrl: manga.coverUrl!,
                  fit: BoxFit.cover,
                  cacheManager: CustomCacheManager.instance,
                  memCacheWidth: 400, // Low-res is fine for blurred background
                  errorWidget: (context, url, error) =>
                      Container(color: colors.inkPanel),
                ),
              ),
            )
          else
            Container(color: colors.inkPanel),

          // Palette tint overlay
          paletteColor.when(
            data: (color) {
              if (color == null) return const SizedBox.shrink();
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.10),
                      color.withValues(alpha: 0.14),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // Bottom gradient
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
              tag: 'cover_${manga.mangaDexId}',
              child: Container(
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  boxShadow: [
                    BoxShadow(
                      color: colors.inkVoid.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  child: manga.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: manga.coverUrl!,
                          fit: BoxFit.cover,
                          cacheManager: CustomCacheManager.instance,
                          memCacheWidth: 260, // 130pt × 2 for pixel density
                          errorWidget: (context, url, error) =>
                              _CoverPlaceholder(colors: colors),
                          progressIndicatorBuilder: (context, url, progress) {
                            if (progress.progress == null) {
                              return _CoverPlaceholder(colors: colors);
                            }
                            return _CoverPlaceholder(
                              colors: colors,
                              showLoading: true,
                            );
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
              icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),

          // Edit button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.edit_outlined, color: colors.textPrimary),
              onPressed: onEdit,
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

  const _CoverPlaceholder({required this.colors, this.showLoading = false});

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
                  valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
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
        if (manga.author != null)
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: colors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                manga.author!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        if (manga.author != null) const SizedBox(height: AppDimensions.space8),

        // Status row
        Row(children: [StatusBadge(status: status)]),
      ],
    );
  }
}

class _Synopsis extends StatefulWidget {
  final String? synopsis;
  final VoidInkColors colors;

  const _Synopsis({required this.synopsis, required this.colors});

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
            style: AppTextStyles.bodySmall.copyWith(
              color: widget.colors.goldSpark,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddToLibraryButton extends StatelessWidget {
  final VoidInkColors colors;
  final VoidCallback onPressed;

  const _AddToLibraryButton({required this.colors, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          StorySyncHaptics.mediumTap();
          onPressed();
        },
        icon: Icon(Icons.add_rounded, color: colors.inkVoid),
        label: Text(
          'Add to Library',
          style: AppTextStyles.titleMedium.copyWith(color: colors.inkVoid),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.goldSpark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
        ),
      ),
    );
  }
}

/// Tracker console displaying status dropdown and chapter stepper.
class _TrackerConsole extends StatelessWidget {
  final MangaItem manga;
  final VoidInkColors colors;
  final ValueChanged<ReadingStatus> onStatusChanged;
  final ValueChanged<int> onChapterChanged;

  const _TrackerConsole({
    required this.manga,
    required this.colors,
    required this.onStatusChanged,
    required this.onChapterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveChapter = manga.chapterProgress;

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
            status: manga.readingStatus,
            colors: colors,
            onChanged: onStatusChanged,
          ),
          const SizedBox(height: AppDimensions.space24),

          // Chapter stepper — uses effective chapter (base + ephemeral offset)
          ChapterStepper(
            currentChapter: effectiveChapter,
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
            StorySyncHaptics.selection();
            onChanged(value);
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/presentation/controllers/library_controller.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/core/utils/snackbar_util.dart';
import 'package:storysync/features/library/widgets/manga_grid_card.dart';
import 'package:storysync/features/library/widgets/manga_list_tile.dart';
import 'package:storysync/features/library/presentation/widgets/manual_add_dialog.dart';
import 'package:storysync/shared/widgets/app_icon.dart';

/// Library screen with grid/list toggle and category tabs
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _isGridView = ValueNotifier(true);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _isGridView.dispose();
    super.dispose();
  }

  Future<void> _refreshMetadata(BuildContext context) async {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.inkSurface,
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
            ),
            const SizedBox(width: AppDimensions.space16),
            Text(
              'Refreshing titles...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final count = await ref
          .read(libraryControllerProvider.notifier)
          .refreshAllMetadata();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            VoidInkSnackbar.showSuccess(
              context,
              'Updated $count manga title${count != 1 ? 's' : ''}',
            );
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            VoidInkSnackbar.showError(
              context,
              'Failed to refresh: ${e.toString()}',
            );
          }
        });
      }
    }
  }

  void _showManualAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ManualAddDialog(
        onSave: (newItem) async {
          await ref.read(libraryControllerProvider.notifier).addManga(newItem);
          if (context.mounted) {
            VoidInkSnackbar.showSuccess(context, 'Title added manually');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final VoidInkColors colors = Theme.of(context).extension<VoidInkColors>()!;

    return Scaffold(
      backgroundColor: colors.inkVoid,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon.small(),
            const SizedBox(width: AppDimensions.space8),
            Text(
              'My Library',
              style: AppTextStyles.headlineMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: colors.textSecondary,
            ),
            tooltip: 'Add Manga Manually',
            onPressed: () => _showManualAddDialog(context),
          ),
          // Refresh metadata button
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.textSecondary),
            tooltip: 'Refresh titles from MangaDex',
            onPressed: () => _refreshMetadata(context),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isGridView,
            builder: (context, isGrid, _) {
              return IconButton(
                icon: Icon(
                  isGrid ? Icons.list_rounded : Icons.grid_view_rounded,
                  color: colors.textSecondary,
                ),
                onPressed: () {
                  _isGridView.value = !_isGridView.value;
                },
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _LibraryTabBar(tabController: _tabController, colors: colors),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LibraryContentWrapper(
            status: ReadingStatus.reading,
            isGridView: _isGridView,
            colors: colors,
          ),
          _LibraryContentWrapper(
            status: ReadingStatus.completed,
            isGridView: _isGridView,
            colors: colors,
          ),
          _LibraryContentWrapper(
            status: ReadingStatus.onHold,
            isGridView: _isGridView,
            colors: colors,
          ),
          _LibraryContentWrapper(
            status: ReadingStatus.planToRead,
            isGridView: _isGridView,
            colors: colors,
          ),
          _LibraryContentWrapper(
            status: ReadingStatus.dropped,
            isGridView: _isGridView,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _LibraryTabBar extends StatelessWidget {
  final TabController tabController;
  final VoidInkColors colors;

  const _LibraryTabBar({required this.tabController, required this.colors});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorColor: colors.goldSpark,
      indicatorWeight: 2,
      dividerColor: Colors.transparent,
      labelColor: colors.goldSpark,
      unselectedLabelColor: colors.textSecondary,
      labelStyle: AppTextStyles.labelMedium,
      tabs: const [
        Tab(text: 'Reading'),
        Tab(text: 'Completed'),
        Tab(text: 'On Hold'),
        Tab(text: 'Plan to Read'),
        Tab(text: 'Dropped'),
      ],
    );
  }
}

class _LibraryContentWrapper extends ConsumerWidget {
  final ReadingStatus status;
  final ValueNotifier<bool> isGridView;
  final VoidInkColors colors;

  const _LibraryContentWrapper({
    required this.status,
    required this.isGridView,
    required this.colors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMangaList = ref.watch(libraryByStatusProvider(status));

    return asyncMangaList.when(
      data: (items) {
        if (items.isEmpty) {
          return _EmptyState(status: status, colors: colors);
        }

        return ValueListenableBuilder<bool>(
          valueListenable: isGridView,
          builder: (context, isGrid, _) {
            return RefreshIndicator(
              color: colors.goldSpark,
              backgroundColor: colors.inkSurface,
              onRefresh: () async {
                // Invalidate the provider to trigger a refresh
                ref.invalidate(libraryByStatusProvider(status));
              },
              child: isGrid
                  ? _GridViewList(
                      items: items,
                      onDetails: (manga) =>
                          context.push('/details/${manga.mangaDexId}'),
                      onIncrement: (manga) =>
                          _incrementChapter(context, ref, manga),
                    )
                  : _ListViewList(
                      items: items,
                      colors: colors,
                      onDetails: (manga) =>
                          context.push('/details/${manga.mangaDexId}'),
                      onIncrement: (manga) =>
                          _incrementChapter(context, ref, manga),
                    ),
            );
          },
        );
      },
      loading: () => _ShimmerSkeleton(colors: colors),
      error: (error, stack) => _ErrorState(
        error: error.toString(),
        colors: colors,
        onRetry: () => ref.invalidate(libraryByStatusProvider(status)),
      ),
    );
  }

  Future<void> _incrementChapter(
    BuildContext context,
    WidgetRef ref,
    MangaItem manga,
  ) async {
    final success = await ref
        .read(libraryControllerProvider.notifier)
        .incrementChapter(manga.mangaDexId);

    if (context.mounted) {
      if (!success) {
        VoidInkSnackbar.showError(context, 'Already at max chapters');
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final ReadingStatus status;
  final VoidInkColors colors;

  const _EmptyState({required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 64, color: colors.textHint),
          const SizedBox(height: AppDimensions.space16),
          Text(
            'No ${status.displayLabel.toLowerCase()} manga',
            style: AppTextStyles.titleMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Search for manga to add to your library',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidInkColors colors;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.colors,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colors.textHint),
            const SizedBox(height: AppDimensions.space16),
            Text(
              'Something went wrong',
              style: AppTextStyles.titleMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space16),
            TextButton(
              onPressed: onRetry,
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
}

class _ShimmerSkeleton extends StatelessWidget {
  final VoidInkColors colors;

  const _ShimmerSkeleton({required this.colors});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.space16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.space12,
        crossAxisSpacing: AppDimensions.space12,
        childAspectRatio:
            AppDimensions.gridCardWidth / AppDimensions.gridCardHeight,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: colors.inkSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(
              color: colors.inkBorder,
              width: AppDimensions.borderThin,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.inkPanel,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusMD),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.inkPanel,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXS,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 12,
                        width: 60,
                        decoration: BoxDecoration(
                          color: colors.inkPanel,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GridViewList extends StatelessWidget {
  final List<MangaItem> items;
  final void Function(MangaItem) onDetails;
  final void Function(MangaItem) onIncrement;

  const _GridViewList({
    required this.items,
    required this.onDetails,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.space16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppDimensions.space12,
            crossAxisSpacing: AppDimensions.space12,
            childAspectRatio:
                AppDimensions.gridCardWidth / AppDimensions.gridCardHeight,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final MangaItem manga = items[index];
            return MangaGridCard(
              manga: manga,
              onTap: () => onDetails(manga),
              onQuickIncrement: () => onIncrement(manga),
            );
          },
        );
      },
    );
  }
}

class _ListViewList extends StatelessWidget {
  final List<MangaItem> items;
  final VoidInkColors colors;
  final void Function(MangaItem) onDetails;
  final void Function(MangaItem) onIncrement;

  const _ListViewList({
    required this.items,
    required this.colors,
    required this.onDetails,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.space16),
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          Divider(color: colors.inkBorder, height: 1),
      itemBuilder: (context, index) {
        final MangaItem manga = items[index];
        return MangaListTile(
          manga: manga,
          onTap: () => onDetails(manga),
          onQuickIncrement: () => onIncrement(manga),
        );
      },
    );
  }
}

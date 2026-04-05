import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/core/models/manga_item.dart';
import 'package:storysync/core/models/reading_status.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/core/utils/snackbar_util.dart';
import 'package:storysync/features/library/widgets/manga_grid_card.dart';
import 'package:storysync/features/library/widgets/manga_list_tile.dart';
import 'package:storysync/shared/widgets/app_icon.dart';

/// Library screen with grid/list toggle and category tabs
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _isGridView = ValueNotifier(true);
  late TabController _tabController;

  // Demo data - replace with actual Isar data
  final List<MangaItem> _demoItems = [
    const MangaItem(
      id: '1',
      title: 'Solo Leveling',
      author: 'Chugong',
      coverUrl:
          'https://uploads.mangadex.org/covers/32d76d19-8a05-4db0-9fc2-e0b0648fe9d0/e90bdc47-c8b9-4df7-b2c0-17641b645ee1.jpg',
      status: ReadingStatus.reading,
      currentChapter: 134,
      totalChapters: 179,
    ),
    const MangaItem(
      id: '2',
      title: 'One Piece',
      author: 'Eiichiro Oda',
      coverUrl:
          'https://uploads.mangadex.org/covers/a1c7c817-4e59-43b7-9365-09675a149a6f/2c1b4e1a-5c5f-4efa-96d8-f7e3c6e0c8d5.jpg',
      status: ReadingStatus.reading,
      currentChapter: 1089,
      totalChapters: null,
    ),
    const MangaItem(
      id: '3',
      title: 'Chainsaw Man',
      author: 'Tatsuki Fujimoto',
      status: ReadingStatus.completed,
      currentChapter: 97,
      totalChapters: 97,
    ),
    const MangaItem(
      id: '4',
      title: 'Vagabond',
      author: 'Takehiko Inoue',
      status: ReadingStatus.onHold,
      currentChapter: 200,
      totalChapters: 327,
    ),
    const MangaItem(
      id: '5',
      title: 'Berserk',
      author: 'Kentaro Miura',
      status: ReadingStatus.planToRead,
      currentChapter: 0,
      totalChapters: 374,
    ),
    const MangaItem(
      id: '6',
      title: 'Tower of God',
      author: 'SIU',
      status: ReadingStatus.reading,
      currentChapter: 450,
      totalChapters: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _isGridView.dispose();
    super.dispose();
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
            items: _demoItems,
            status: ReadingStatus.reading,
            isGridView: _isGridView,
            colors: colors,
          ),
          _LibraryContentWrapper(
            items: _demoItems,
            status: ReadingStatus.completed,
            isGridView: _isGridView,
            colors: colors,
          ),
          _LibraryContentWrapper(
            items: _demoItems,
            status: ReadingStatus.onHold,
            isGridView: _isGridView,
            colors: colors,
          ),
          _LibraryContentWrapper(
            items: _demoItems,
            status: ReadingStatus.planToRead,
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
      ],
    );
  }
}

class _LibraryContentWrapper extends StatelessWidget {
  final List<MangaItem> items;
  final ReadingStatus status;
  final ValueNotifier<bool> isGridView;
  final VoidInkColors colors;

  const _LibraryContentWrapper({
    required this.items,
    required this.status,
    required this.isGridView,
    required this.colors,
  });

  Future<void> _onRefresh() async {
    // TODO: Refresh data from API/Isar when integrated
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final List<MangaItem> filteredItems = items
        .where((item) => item.status == status)
        .toList();

    if (filteredItems.isEmpty) {
      return _EmptyState(status: status, colors: colors);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isGridView,
      builder: (context, isGrid, _) {
        return RefreshIndicator(
          color: colors.goldSpark,
          backgroundColor: colors.inkSurface,
          onRefresh: _onRefresh,
          child: isGrid
              ? _GridViewList(
                  items: filteredItems,
                  onDetails: (manga) => context.push('/details/${manga.id}'),
                  onIncrement: (manga) => _incrementChapter(context, manga),
                )
              : _ListViewList(
                  items: filteredItems,
                  colors: colors,
                  onDetails: (manga) => context.push('/details/${manga.id}'),
                  onIncrement: (manga) => _incrementChapter(context, manga),
                ),
        );
      },
    );
  }

  void _incrementChapter(BuildContext context, MangaItem manga) {
    // TODO: Implement chapter increment with Isar
    VoidInkSnackbar.showSuccess(context, '+1 Chapter Logged');
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

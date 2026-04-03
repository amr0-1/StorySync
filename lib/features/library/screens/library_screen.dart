import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtrack/core/models/manga_item.dart';
import 'package:mtrack/core/models/reading_status.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';
import 'package:mtrack/features/library/widgets/manga_grid_card.dart';
import 'package:mtrack/features/library/widgets/manga_list_tile.dart';

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
    return Scaffold(
      backgroundColor: AppColors.inkVoid,
      appBar: AppBar(
        title: Text('My Library', style: AppTextStyles.headlineMedium),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isGridView,
            builder: (context, isGrid, _) {
              return IconButton(
                icon: Icon(
                  isGrid ? Icons.list_rounded : Icons.grid_view_rounded,
                  color: AppColors.textSecondary,
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
          child: _buildTabBar(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLibraryContent(ReadingStatus.reading),
          _buildLibraryContent(ReadingStatus.completed),
          _buildLibraryContent(ReadingStatus.onHold),
          _buildLibraryContent(ReadingStatus.planToRead),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorColor: AppColors.goldSpark,
      indicatorWeight: 2,
      dividerColor: Colors.transparent,
      labelColor: AppColors.goldSpark,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.labelMedium,
      tabs: const [
        Tab(text: 'Reading'),
        Tab(text: 'Completed'),
        Tab(text: 'On Hold'),
        Tab(text: 'Plan to Read'),
      ],
    );
  }

  Widget _buildLibraryContent(ReadingStatus filterStatus) {
    final filteredItems = _demoItems
        .where((item) => item.status == filterStatus)
        .toList();

    if (filteredItems.isEmpty) {
      return _buildEmptyState(filterStatus);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _isGridView,
      builder: (context, isGrid, _) {
        if (isGrid) {
          return _buildGridView(filteredItems);
        }
        return _buildListView(filteredItems);
      },
    );
  }

  Widget _buildEmptyState(ReadingStatus status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppDimensions.space16),
          Text(
            'No ${status.displayLabel.toLowerCase()} manga',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Search for manga to add to your library',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<MangaItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
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
            final manga = items[index];
            return MangaGridCard(
              manga: manga,
              onTap: () => _navigateToDetails(manga),
              onQuickIncrement: () => _incrementChapter(manga),
            );
          },
        );
      },
    );
  }

  Widget _buildListView(List<MangaItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.space16),
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const Divider(color: AppColors.inkBorder, height: 1),
      itemBuilder: (context, index) {
        final manga = items[index];
        return MangaListTile(
          manga: manga,
          onTap: () => _navigateToDetails(manga),
          onQuickIncrement: () => _incrementChapter(manga),
        );
      },
    );
  }

  void _navigateToDetails(MangaItem manga) {
    context.push('/details/${manga.id}');
  }

  void _incrementChapter(MangaItem manga) {
    // TODO: Implement chapter increment with Isar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${manga.title}: Chapter ${manga.currentChapter + 1}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.inkPanel,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

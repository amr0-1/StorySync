import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';

/// Search and discover screen for finding new manga
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;
  List<_SearchResult> _results = [];

  // Filter state
  Set<String> _selectedDemographics = {};
  Set<String> _selectedStatuses = {};

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkVoid,
      appBar: AppBar(
        title: Text('Discover', style: AppTextStyles.headlineMedium),
      ),
      body: Column(
        children: [
          // Search header
          _buildSearchHeader(),

          // Results
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search manga, manhwa, manhua...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textHint,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.textHint,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                          });
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          // Filter button
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: _hasActiveFilters
                  ? AppColors.goldSpark
                  : AppColors.textSecondary,
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _selectedDemographics.isNotEmpty || _selectedStatuses.isNotEmpty;

  Widget _buildContent() {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldSpark),
        ),
      );
    }

    if (_results.isEmpty) {
      return _buildNoResults();
    }

    return _buildResultsList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_rounded, size: 64, color: AppColors.textHint),
          const SizedBox(height: AppDimensions.space16),
          Text(
            'Search for your favorite manga',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Powered by MangaDex',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppDimensions.space16),
          Text(
            'No results found',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.space16),
      itemCount: _results.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppDimensions.space12),
      itemBuilder: (context, index) {
        final result = _results[index];
        return _DiscoverResultTile(
          result: result,
          onTap: () => _navigateToDetails(result),
          onAdd: () => _addToLibrary(result),
        );
      },
    );
  }

  void _onSearchChanged(String value) {
    setState(() {}); // Update UI for clear button

    if (value.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    // Debounce search
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(value);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
    });

    // TODO: Implement actual MangaDex API search
    // For now, simulate search with demo data
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _results = _demoSearchResults
          .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.inkPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusMD),
        ),
      ),
      builder: (context) => _FilterBottomSheet(
        selectedDemographics: _selectedDemographics,
        selectedStatuses: _selectedStatuses,
        onApply: (demographics, statuses) {
          setState(() {
            _selectedDemographics = demographics;
            _selectedStatuses = statuses;
          });
          if (_searchController.text.isNotEmpty) {
            _performSearch(_searchController.text);
          }
        },
      ),
    );
  }

  void _navigateToDetails(_SearchResult result) {
    context.push('/details/${result.id}');
  }

  void _addToLibrary(_SearchResult result) {
    // TODO: Implement actual Isar save
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.goldSpark,
              size: 20,
            ),
            const SizedBox(width: AppDimensions.space8),
            Text(
              'Added to Library',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.inkPanel,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Filter bottom sheet
class _FilterBottomSheet extends StatefulWidget {
  final Set<String> selectedDemographics;
  final Set<String> selectedStatuses;
  final void Function(Set<String> demographics, Set<String> statuses) onApply;

  const _FilterBottomSheet({
    required this.selectedDemographics,
    required this.selectedStatuses,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late Set<String> _demographics;
  late Set<String> _statuses;

  @override
  void initState() {
    super.initState();
    _demographics = Set.from(widget.selectedDemographics);
    _statuses = Set.from(widget.selectedStatuses);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with gold border
          Container(
            padding: const EdgeInsets.only(bottom: AppDimensions.space12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.goldSpark,
                  width: AppDimensions.borderThin,
                ),
              ),
            ),
            child: Row(
              children: [
                Text('Filter Results', style: AppTextStyles.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _demographics.clear();
                      _statuses.clear();
                    });
                  },
                  child: Text(
                    'Clear',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.goldSpark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Demographic filters
          Text('DEMOGRAPHIC', style: AppTextStyles.overline),
          const SizedBox(height: AppDimensions.space8),
          Wrap(
            spacing: AppDimensions.space8,
            runSpacing: AppDimensions.space8,
            children: ['Shounen', 'Seinen', 'Josei', 'Shoujo']
                .map(
                  (d) => _FilterChipWidget(
                    label: d,
                    isSelected: _demographics.contains(d),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _demographics.add(d);
                        } else {
                          _demographics.remove(d);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Status filters
          Text('STATUS', style: AppTextStyles.overline),
          const SizedBox(height: AppDimensions.space8),
          Wrap(
            spacing: AppDimensions.space8,
            runSpacing: AppDimensions.space8,
            children: ['Publishing', 'Finished', 'Hiatus', 'Cancelled']
                .map(
                  (s) => _FilterChipWidget(
                    label: s,
                    isSelected: _statuses.contains(s),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _statuses.add(s);
                        } else {
                          _statuses.remove(s);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_demographics, _statuses);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inkPanel,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  side: const BorderSide(
                    color: AppColors.inkBorder,
                    width: AppDimensions.borderThin,
                  ),
                ),
              ),
              child: Text('Apply', style: AppTextStyles.titleMedium),
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
        ],
      ),
    );
  }
}

/// Custom filter chip
class _FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FilterChipWidget({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.goldSpark.withValues(alpha: 0.15),
      checkmarkColor: AppColors.goldSpark,
      side: BorderSide(
        color: isSelected ? AppColors.goldSpark : AppColors.inkBorder,
        width: AppDimensions.borderThin,
      ),
    );
  }
}

/// Search result tile
class _DiscoverResultTile extends StatelessWidget {
  final _SearchResult result;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _DiscoverResultTile({
    required this.result,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          color: AppColors.inkSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          border: Border.all(
            color: AppColors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        child: Row(
          children: [
            // Cover thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
              child: SizedBox(
                width: 50,
                height: 68,
                child: result.coverUrl != null
                    ? Image.network(
                        result.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildCoverPlaceholder(),
                      )
                    : _buildCoverPlaceholder(),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.author ?? 'Unknown',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildStatusPill(),
                ],
              ),
            ),

            // Add button
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.goldSpark,
              ),
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      color: AppColors.inkPanel,
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 20,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildStatusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.inkPanel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: AppColors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Text(
        result.status,
        style: AppTextStyles.overline.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

/// Demo search result model
class _SearchResult {
  final String id;
  final String title;
  final String? author;
  final String? coverUrl;
  final String status;

  const _SearchResult({
    required this.id,
    required this.title,
    this.author,
    this.coverUrl,
    required this.status,
  });
}

// Demo search results
const _demoSearchResults = [
  _SearchResult(
    id: 'demo-1',
    title: 'Solo Leveling',
    author: 'Chugong',
    status: 'Finished',
  ),
  _SearchResult(
    id: 'demo-2',
    title: 'Solo Max-Level Newbie',
    author: 'Maslow',
    status: 'Publishing',
  ),
  _SearchResult(
    id: 'demo-3',
    title: 'The Beginning After The End',
    author: 'TurtleMe',
    status: 'Publishing',
  ),
  _SearchResult(
    id: 'demo-4',
    title: 'Omniscient Reader\'s Viewpoint',
    author: 'Sing Shong',
    status: 'Publishing',
  ),
  _SearchResult(
    id: 'demo-5',
    title: 'Tower of God',
    author: 'SIU',
    status: 'Publishing',
  ),
];

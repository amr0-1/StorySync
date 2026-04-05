import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/core/utils/snackbar_util.dart';
import 'package:storysync/shared/widgets/app_icon.dart';

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
              'Discover',
              style: AppTextStyles.headlineMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search header
          _SearchHeader(
            controller: _searchController,
            hasActiveFilters: _hasActiveFilters,
            colors: colors,
            onSearchChanged: _onSearchChanged,
            onClear: () {
              _searchController.clear();
              setState(() {
                _results = [];
              });
            },
            onFilterTapped: _showFilterSheet,
          ),

          // Results
          Expanded(
            child: _DiscoverContent(
              controller: _searchController,
              isSearching: _isSearching,
              results: _results,
              colors: colors,
              onRefresh: _onRefresh,
              onDetails: _navigateToDetails,
              onAdd: _addToLibrary,
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _selectedDemographics.isNotEmpty || _selectedStatuses.isNotEmpty;

  Future<void> _onRefresh() async {
    // TODO: Refresh search results from API when integrated
    if (_searchController.text.isNotEmpty) {
      await _performSearch(_searchController.text);
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }
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
      builder: (ctx) => _FilterBottomSheet(
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
    VoidInkSnackbar.showSuccess(context, 'Added to Library');
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final bool hasActiveFilters;
  final VoidInkColors colors;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterTapped;

  const _SearchHeader({
    required this.controller,
    required this.hasActiveFilters,
    required this.colors,
    required this.onSearchChanged,
    required this.onClear,
    required this.onFilterTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search manga, manhwa, manhua...',
                prefixIcon: Icon(Icons.search_rounded, color: colors.textHint),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: colors.textHint),
                        onPressed: onClear,
                      )
                    : null,
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          // Filter button
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: hasActiveFilters ? colors.goldSpark : colors.textSecondary,
            ),
            onPressed: onFilterTapped,
          ),
        ],
      ),
    );
  }
}

class _DiscoverContent extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final List<_SearchResult> results;
  final VoidInkColors colors;
  final Future<void> Function() onRefresh;
  final void Function(_SearchResult) onDetails;
  final void Function(_SearchResult) onAdd;

  const _DiscoverContent({
    required this.controller,
    required this.isSearching,
    required this.results,
    required this.colors,
    required this.onRefresh,
    required this.onDetails,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.text.isEmpty) {
      return _EmptyState(colors: colors);
    }

    if (isSearching) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
        ),
      );
    }

    if (results.isEmpty) {
      return _NoResultsState(colors: colors);
    }

    return _ResultsList(
      results: results,
      colors: colors,
      onRefresh: onRefresh,
      onDetails: onDetails,
      onAdd: onAdd,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidInkColors colors;

  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 64, color: colors.textHint),
          const SizedBox(height: AppDimensions.space16),
          Text(
            'Search for your favorite manga',
            style: AppTextStyles.titleMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Powered by MangaDex',
            style: AppTextStyles.bodySmall.copyWith(color: colors.textHint),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final VoidInkColors colors;

  const _NoResultsState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: colors.textHint),
          const SizedBox(height: AppDimensions.space16),
          Text(
            'No results found',
            style: AppTextStyles.titleMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<_SearchResult> results;
  final VoidInkColors colors;
  final Future<void> Function() onRefresh;
  final void Function(_SearchResult) onDetails;
  final void Function(_SearchResult) onAdd;

  const _ResultsList({
    required this.results,
    required this.colors,
    required this.onRefresh,
    required this.onDetails,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: colors.goldSpark,
      backgroundColor: colors.inkSurface,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.space16),
        itemCount: results.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppDimensions.space12),
        itemBuilder: (context, index) {
          final _SearchResult result = results[index];
          return _DiscoverResultTile(
            result: result,
            onTap: () => onDetails(result),
            onAdd: () => onAdd(result),
          );
        },
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
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with gold border
          Container(
            padding: const EdgeInsets.only(bottom: AppDimensions.space12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.goldSpark,
                  width: AppDimensions.borderThin,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Filter Results',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
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
                      color: colors.goldSpark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Demographic filters
          Text(
            'DEMOGRAPHIC',
            style: AppTextStyles.overline.copyWith(color: colors.textHint),
          ),
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
          Text(
            'STATUS',
            style: AppTextStyles.overline.copyWith(color: colors.textHint),
          ),
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
                backgroundColor: colors.inkPanel,
                foregroundColor: colors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  side: BorderSide(
                    color: colors.inkBorder,
                    width: AppDimensions.borderThin,
                  ),
                ),
              ),
              child: Text(
                'Apply',
                style: AppTextStyles.titleMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
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
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: colors.goldSpark.withValues(alpha: 0.15),
      checkmarkColor: colors.goldSpark,
      side: BorderSide(
        color: isSelected ? colors.goldSpark : colors.inkBorder,
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
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          color: colors.inkSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          border: Border.all(
            color: colors.inkBorder,
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
                        errorBuilder: (_, error, stack) =>
                            _buildCoverPlaceholder(colors),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildCoverPlaceholder(
                            colors,
                            showLoading: true,
                          );
                        },
                      )
                    : _buildCoverPlaceholder(colors),
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
                    style: AppTextStyles.titleSmall.copyWith(
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.author ?? 'Unknown',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildStatusPill(colors),
                ],
              ),
            ),

            // Add button
            IconButton(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: colors.goldSpark,
              ),
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder(
    VoidInkColors colors, {
    bool showLoading = false,
  }) {
    return Container(
      color: colors.inkPanel,
      child: Center(
        child: showLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.goldSpark),
                ),
              )
            : Icon(
                Icons.image_not_supported_outlined,
                size: 20,
                color: colors.textHint,
              ),
      ),
    );
  }

  Widget _buildStatusPill(VoidInkColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.inkPanel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Text(
        result.status,
        style: AppTextStyles.overline.copyWith(color: colors.textSecondary),
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
    coverUrl:
        'https://uploads.mangadex.org/covers/32d76d19-8a05-4db0-9fc2-e0b0648fe9d0/e90bdc47-c8b9-4df7-b2c0-17641b645ee1.jpg',
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

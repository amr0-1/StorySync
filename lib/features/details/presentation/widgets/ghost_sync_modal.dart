import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/core/utils/haptic_util.dart';
import 'package:storysync/core/utils/snackbar_util.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:isar/isar.dart';
import 'package:storysync/features/insights/data/analytics_providers.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/presentation/controllers/library_controller.dart';
import 'package:storysync/features/library/providers/backfill_provider.dart';

/// Shows the Ghost Sync bottom sheet for the given manga.
///
/// Call this from the details screen / tracker console.
void showGhostSyncModal(
  BuildContext context, {
  required String mangaDexId,
  required int currentChapter,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => GhostSyncModal(
      mangaDexId: mangaDexId,
      currentChapter: currentChapter,
    ),
  );
}

// ════════════════════════════════════════════════════════════════════
// Ghost Sync Modal
// ════════════════════════════════════════════════════════════════════

class GhostSyncModal extends ConsumerStatefulWidget {
  final String mangaDexId;
  final int currentChapter;

  const GhostSyncModal({
    super.key,
    required this.mangaDexId,
    required this.currentChapter,
  });

  @override
  ConsumerState<GhostSyncModal> createState() => _GhostSyncModalState();
}

class _GhostSyncModalState extends ConsumerState<GhostSyncModal> {
  BackfillMode _selectedMode = BackfillMode.stealth;
  final _chapterController = TextEditingController();
  double _spreadMonths = 3;
  DateTime _customDate = DateTime.now().subtract(const Duration(days: 30));
  bool _isSyncing = false;

  @override
  void dispose() {
    _chapterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.inkSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLG),
        ),
        border: Border(
          top: BorderSide(
            color: colors.inkBorder,
            width: AppDimensions.borderThin,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              const SizedBox(height: AppDimensions.space12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.inkMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space24,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 20,
                      color: colors.goldSpark,
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    Text(
                      'Sync Past Progress',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space4),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space24,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Backfill chapters you\'ve already read elsewhere.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // ── Segmented Control ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space24,
                ),
                child: _GhostModeSelector(
                  selectedMode: _selectedMode,
                  colors: colors,
                  onModeChanged: (mode) {
                    StorySyncHaptics.selection();
                    setState(() => _selectedMode = mode);
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // ── Mode-Specific Content ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space24,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _buildModeContent(colors),
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // ── Chapter Count Input ───────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space24,
                ),
                child: _ChapterCountField(
                  controller: _chapterController,
                  colors: colors,
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // ── Sync Button ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space24,
                ),
                child: _SyncButton(
                  colors: colors,
                  isSyncing: _isSyncing,
                  onPressed: _handleSync,
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).padding.bottom +
                    AppDimensions.space16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mode-specific content builder ───────────────────────────────

  Widget _buildModeContent(VoidInkColors colors) {
    return switch (_selectedMode) {
      BackfillMode.stealth => _StealthModeContent(
          key: const ValueKey('stealth'),
          colors: colors,
        ),
      BackfillMode.spread => _SpreadModeContent(
          key: const ValueKey('spread'),
          colors: colors,
          months: _spreadMonths,
          onMonthsChanged: (v) => setState(() => _spreadMonths = v),
        ),
      BackfillMode.customDate => _CustomDateModeContent(
          key: const ValueKey('custom'),
          colors: colors,
          selectedDate: _customDate,
          onDateSelected: (date) => setState(() => _customDate = date),
        ),
    };
  }

  // ── Sync handler ────────────────────────────────────────────────

  Future<void> _handleSync() async {
    final chaptersText = _chapterController.text.trim();
    final chapters = int.tryParse(chaptersText);

    if (chapters == null || chapters <= 0) {
      VoidInkSnackbar.showError(context, 'Enter a valid chapter count');
      return;
    }

    setState(() => _isSyncing = true);

    try {
      final backfillService = ref.read(backfillServiceProvider);

      final config = BackfillConfig(
        mangaDexId: widget.mangaDexId,
        chaptersToSync: chapters,
        mode: _selectedMode,
        spreadMonths: _spreadMonths.round(),
        customDate:
            _selectedMode == BackfillMode.customDate ? _customDate : null,
      );

      final success = await backfillService.executeAdvancedBackfill(config);

      if (!mounted) return;

      if (success) {
        // ── Split-Transaction: Main-thread MangaItem update ──────
        // The isolate only wrote ReadingLogs. We update the title's
        // chapterProgress on the main-thread Isar instance so that
        // its collection watchers fire locally (no cross-isolate race).
        final isarService = ref.read(isarServiceProvider);
        final isar = await isarService.openDB();
        await isar.writeTxn(() async {
          final freshManga = await isar.mangaItems
              .filter()
              .mangaDexIdEqualTo(widget.mangaDexId)
              .findFirst();
          if (freshManga != null) {
            freshManga.chapterProgress =
                widget.currentChapter + chapters;
            // Clamp to totalChapters if known
            if (freshManga.totalChapters != null &&
                freshManga.chapterProgress > freshManga.totalChapters!) {
              freshManga.chapterProgress = freshManga.totalChapters!;
            }
            freshManga.lastUpdated = DateTime.now();
            freshManga.lastReadAt = DateTime.now();
            await isar.mangaItems.put(freshManga);
          }
        });

        if (!mounted) return;

        // ── Invalidate stale Riverpod caches ─────────────────────
        // 1. Details screen's manga stream → TrackerConsole rebuilds
        ref.invalidate(mangaByIdProvider(widget.mangaDexId));
        // 2. Library list/grid → chapter counts in cards update
        ref.invalidate(libraryControllerProvider);
        // 3. Insights tab → heatmap & stats reflect backfilled logs
        ref.invalidate(analyticsSnapshotProvider);

        StorySyncHaptics.mediumTap();
        Navigator.of(context).pop();
        VoidInkSnackbar.showSuccess(
          context,
          'Synced $chapters chapter${chapters == 1 ? '' : 's'} successfully',
        );
      } else {
        VoidInkSnackbar.showError(context, 'Sync failed — please try again');
      }
    } catch (e) {
      if (mounted) {
        VoidInkSnackbar.showError(context, 'Unexpected error during sync');
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }
}

// ════════════════════════════════════════════════════════════════════
// 3-Way Segmented Control
// ════════════════════════════════════════════════════════════════════

class _GhostModeSelector extends StatelessWidget {
  final BackfillMode selectedMode;
  final VoidInkColors colors;
  final ValueChanged<BackfillMode> onModeChanged;

  const _GhostModeSelector({
    required this.selectedMode,
    required this.colors,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.inkPanel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        children: BackfillMode.values.map((mode) {
          final isSelected = mode == selectedMode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.space8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.inkSurface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSM - 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.inkVoid.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _labelFor(mode),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected
                          ? colors.textPrimary
                          : colors.textHint,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _labelFor(BackfillMode mode) => switch (mode) {
        BackfillMode.stealth => 'Stealth',
        BackfillMode.spread => 'Spread',
        BackfillMode.customDate => 'Custom Date',
      };
}

// ════════════════════════════════════════════════════════════════════
// Stealth Mode Content
// ════════════════════════════════════════════════════════════════════

class _StealthModeContent extends StatelessWidget {
  final VoidInkColors colors;

  const _StealthModeContent({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: colors.statusOnHoldBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: colors.statusOnHold.withValues(alpha: 0.25),
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.visibility_off_rounded,
            size: 18,
            color: colors.statusOnHold,
          ),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Text(
              'Chapters will be unlocked but excluded from your '
              'reading statistics.',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Spread Mode Content
// ════════════════════════════════════════════════════════════════════

class _SpreadModeContent extends StatelessWidget {
  final VoidInkColors colors;
  final double months;
  final ValueChanged<double> onMonthsChanged;

  const _SpreadModeContent({
    super.key,
    required this.colors,
    required this.months,
    required this.onMonthsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.space12),
          decoration: BoxDecoration(
            color: colors.statusReadingBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            border: Border.all(
              color: colors.statusReading.withValues(alpha: 0.25),
              width: AppDimensions.borderThin,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: colors.statusReading,
              ),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  'Chapters will be distributed naturally across '
                  'the selected period and appear on your heatmap.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space16),
        Row(
          children: [
            Text(
              'SPREAD OVER',
              style: AppTextStyles.overline.copyWith(
                color: colors.textHint,
              ),
            ),
            const Spacer(),
            Text(
              '${months.round()} month${months.round() == 1 ? '' : 's'}',
              style: AppTextStyles.monoSmall.copyWith(
                color: colors.goldSpark,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: colors.goldSpark,
            inactiveTrackColor: colors.inkPanel,
            thumbColor: colors.goldSpark,
            overlayColor: colors.goldSpark.withValues(alpha: 0.12),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 7,
            ),
          ),
          child: Slider(
            value: months,
            min: 1,
            max: 12,
            divisions: 11,
            onChanged: onMonthsChanged,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Custom Date Mode Content
// ════════════════════════════════════════════════════════════════════

class _CustomDateModeContent extends StatelessWidget {
  final VoidInkColors colors;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CustomDateModeContent({
    super.key,
    required this.colors,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateStr =
        '${months[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.space12),
          decoration: BoxDecoration(
            color: colors.statusPlanToReadBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            border: Border.all(
              color: colors.statusPlanToRead.withValues(alpha: 0.25),
              width: AppDimensions.borderThin,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: colors.statusPlanToRead,
              ),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  'All chapters will be logged on the selected date '
                  'and visible on your heatmap.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space16),
        Text(
          'SELECT DATE',
          style: AppTextStyles.overline.copyWith(color: colors.textHint),
        ),
        const SizedBox(height: AppDimensions.space8),
        GestureDetector(
          onTap: () => _pickDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space12,
              vertical: AppDimensions.space12,
            ),
            decoration: BoxDecoration(
              color: colors.inkPanel,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              border: Border.all(
                color: colors.inkBorder,
                width: AppDimensions.borderThin,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  size: 18,
                  color: colors.goldSpark,
                ),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  dateStr,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.edit_calendar_rounded,
                  size: 16,
                  color: colors.textHint,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: colors.goldSpark,
              onPrimary: colors.inkVoid,
              surface: colors.inkSurface,
              onSurface: colors.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: colors.inkSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      StorySyncHaptics.selection();
      onDateSelected(picked);
    }
  }
}

// ════════════════════════════════════════════════════════════════════
// Chapter Count Input Field
// ════════════════════════════════════════════════════════════════════

class _ChapterCountField extends StatelessWidget {
  final TextEditingController controller;
  final VoidInkColors colors;

  const _ChapterCountField({
    required this.controller,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHAPTERS TO SYNC',
          style: AppTextStyles.overline.copyWith(color: colors.textHint),
        ),
        const SizedBox(height: AppDimensions.space8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.monoMedium.copyWith(
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. 50',
            hintStyle: AppTextStyles.monoMedium.copyWith(
              color: colors.textHint,
            ),
            filled: true,
            fillColor: colors.inkPanel,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space12,
              vertical: AppDimensions.space12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(
                color: colors.inkBorder,
                width: AppDimensions.borderThin,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(
                color: colors.inkBorder,
                width: AppDimensions.borderThin,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(
                color: colors.goldSpark,
                width: AppDimensions.borderMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Sync Button
// ════════════════════════════════════════════════════════════════════

class _SyncButton extends StatelessWidget {
  final VoidInkColors colors;
  final bool isSyncing;
  final VoidCallback onPressed;

  const _SyncButton({
    required this.colors,
    required this.isSyncing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isSyncing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.goldSpark,
          disabledBackgroundColor: colors.goldDim,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
        ),
        child: isSyncing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.inkVoid),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sync_rounded,
                    size: 18,
                    color: colors.inkVoid,
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    'Sync',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: colors.inkVoid,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

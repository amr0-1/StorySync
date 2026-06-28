import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/data/models/reading_log.dart';

// ════════════════════════════════════════════════════════════════════
// Backfill Mode & Configuration
// ════════════════════════════════════════════════════════════════════

/// The three Ghost Sync strategies.
enum BackfillMode {
  /// Chapters logged on today's date, fully excluded from analytics.
  stealth,

  /// Chapters distributed across a configurable time window, visible
  /// on the heatmap as organic-looking logs.
  spread,

  /// All chapters logged on a single user-selected historical date,
  /// visible on the heatmap.
  customDate,
}

/// Immutable payload describing a backfill operation.
///
/// Kept lightweight so it can cross the isolate boundary as part of
/// a [_BackfillPayload] without requiring heavy serialization.
class BackfillConfig {
  final String mangaDexId;
  final int chaptersToSync;
  final BackfillMode mode;

  /// Only used when [mode] == [BackfillMode.spread].
  final int spreadMonths;

  /// Only used when [mode] == [BackfillMode.customDate].
  final DateTime? customDate;

  const BackfillConfig({
    required this.mangaDexId,
    required this.chaptersToSync,
    required this.mode,
    this.spreadMonths = 3,
    this.customDate,
  });
}

// ════════════════════════════════════════════════════════════════════
// Isolate Payload (primitives + serialisable data only)
// ════════════════════════════════════════════════════════════════════

class _BackfillPayload {
  final String dirPath;
  final String mangaDexId;
  final int chaptersToSync;
  final BackfillMode mode;
  final int spreadMonths;
  final DateTime? customDate;

  const _BackfillPayload({
    required this.dirPath,
    required this.mangaDexId,
    required this.chaptersToSync,
    required this.mode,
    required this.spreadMonths,
    this.customDate,
  });
}

// ════════════════════════════════════════════════════════════════════
// Static Isolate Entry Point
// ════════════════════════════════════════════════════════════════════

/// Runs entirely inside [Isolate.run]. Opens its own Isar instance,
/// writes backfill logs, and returns a primitive [bool].
///
/// **SYSTEM_BOUNDARIES §1:** Bulk operation in isolate, returns bool,
/// closes Isar in `finally`.
Future<bool> _executeBackfillInIsolate(_BackfillPayload payload) async {
  Isar? isar;
  try {
    isar = Isar.getInstance('storysync_db');
    isar ??= await Isar.open(
      [MangaItemSchema, ReadingLogSchema],
      directory: payload.dirPath,
      name: 'storysync_db',
    );

    final logs = <ReadingLog>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (payload.mode) {
      case BackfillMode.stealth:
        // All chapters on today's date, isPastReading = true (invisible).
        logs.add(ReadingLog.create(
          date: today,
          mangaDexId: payload.mangaDexId,
          chaptersRead: payload.chaptersToSync,
          exactTimestamp: now,
          isPastReading: true,
        ));

      case BackfillMode.spread:
        // Distribute chapters across `spreadMonths` as organic logs.
        final totalDays = payload.spreadMonths * 30;
        final rng = Random();
        int remaining = payload.chaptersToSync;

        // Generate random day offsets, sorted ascending.
        final offsets = <int>{};
        final targetBuckets = min(remaining, totalDays);
        while (offsets.length < targetBuckets) {
          offsets.add(rng.nextInt(totalDays));
        }
        final sortedOffsets = offsets.toList()..sort();

        // Distribute chapters across the selected days.
        for (int i = 0; i < sortedOffsets.length && remaining > 0; i++) {
          final isLast = i == sortedOffsets.length - 1;
          final chaptersForDay = isLast
              ? remaining
              : max(1, (remaining / (sortedOffsets.length - i)).round());
          final allocated = min(chaptersForDay, remaining);
          remaining -= allocated;

          final date = today.subtract(Duration(days: sortedOffsets[i]));
          final normalizedDate = DateTime(date.year, date.month, date.day);

          logs.add(ReadingLog.create(
            date: normalizedDate,
            mangaDexId: payload.mangaDexId,
            chaptersRead: allocated,
            exactTimestamp: DateTime(
              normalizedDate.year,
              normalizedDate.month,
              normalizedDate.day,
              8 + rng.nextInt(14), // Random hour 8–21
              rng.nextInt(60),
            ),
            isPastReading: false, // Visible on heatmap.
          ));
        }

      case BackfillMode.customDate:
        // All chapters on the user-selected date, visible on heatmap.
        final date = payload.customDate ?? today;
        final normalizedDate = DateTime(date.year, date.month, date.day);

        logs.add(ReadingLog.create(
          date: normalizedDate,
          mangaDexId: payload.mangaDexId,
          chaptersRead: payload.chaptersToSync,
          exactTimestamp: DateTime(
            normalizedDate.year,
            normalizedDate.month,
            normalizedDate.day,
            12, 0,
          ),
          isPastReading: false, // Visible on heatmap.
        ));
    }

    // Batch write in a single transaction.
    await isar.writeTxn(() async {
      await isar!.readingLogs.putAll(logs);
    });

    return true;
  } catch (_) {
    return false;
  } finally {
    // §1: Background isolates must ALWAYS call isar.close() in finally.
    if (isar != null && isar.isOpen) {
      await isar.close();
    }
  }
}

// ════════════════════════════════════════════════════════════════════
// BackfillService (public API)
// ════════════════════════════════════════════════════════════════════

/// Service that orchestrates Ghost Sync backfill operations.
///
/// All heavy lifting is delegated to [Isolate.run] via [compute].
/// The UI layer calls [executeAdvancedBackfill] and awaits a [bool].
class BackfillService {
  final IsarService _isarService;

  const BackfillService(this._isarService);

  /// Execute the backfill operation in a background isolate.
  ///
  /// Returns `true` on success, `false` on failure.
  /// Never throws — errors are caught inside the isolate.
  Future<bool> executeAdvancedBackfill(BackfillConfig config) async {
    final dirPath = await _isarService.getDbDirectory();

    final payload = _BackfillPayload(
      dirPath: dirPath,
      mangaDexId: config.mangaDexId,
      chaptersToSync: config.chaptersToSync,
      mode: config.mode,
      spreadMonths: config.spreadMonths,
      customDate: config.customDate,
    );

    return compute(_executeBackfillInIsolate, payload);
  }
}

// ════════════════════════════════════════════════════════════════════
// Riverpod Provider
// ════════════════════════════════════════════════════════════════════

/// Provider exposing the [BackfillService].
///
/// **SYSTEM_BOUNDARIES §2:** Dedicated provider — does not touch
/// analytics_providers.dart or library_controller.dart.
final backfillServiceProvider = Provider<BackfillService>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return BackfillService(isarService);
});

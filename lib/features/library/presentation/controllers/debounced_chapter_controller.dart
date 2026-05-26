import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/core/native/widget_service.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';

/// Ephemeral chapter offset state — tracks pending increments that haven't
/// been flushed to Isar yet. Keyed by mangaDexId.
///
/// The UI reads `chapterProgress + offset` for instant feedback.
/// The actual DB write is debounced at 800ms via rxdart.
final chapterOffsetProvider =
    StateNotifierProvider<ChapterOffsetNotifier, Map<String, int>>((ref) {
  return ChapterOffsetNotifier(ref);
});

class ChapterOffsetNotifier extends StateNotifier<Map<String, int>> {
  final Ref _ref;

  /// Subject that receives mangaDexIds to debounce.
  /// Each emission triggers a flush for that specific manga after 800ms idle.
  final _flushSubject = PublishSubject<String>();

  /// Track pending flush subscriptions per manga to avoid duplicate timers.
  final Map<String, StreamSubscription<String>> _subscriptions = {};

  /// Track the status of each manga so we can apply guards without
  /// another Isar lookup on every tap.
  final Map<String, _MangaGuardData> _guardCache = {};

  ChapterOffsetNotifier(this._ref) : super({});

  /// Increment the ephemeral offset for a manga by 1.
  ///
  /// Returns `true` if the increment was accepted (guard passed),
  /// `false` if the manga is completed or at max chapters.
  Future<bool> increment(String mangaDexId) async {
    // Ensure guard data is cached
    if (!_guardCache.containsKey(mangaDexId)) {
      final isarService = _ref.read(isarServiceProvider);
      final manga = await isarService.getMangaByMangaDexId(mangaDexId);
      if (manga == null) return false;
      _guardCache[mangaDexId] = _MangaGuardData(
        status: manga.readingStatus,
        chapterProgress: manga.chapterProgress,
        totalChapters: manga.totalChapters,
      );
    }

    final guard = _guardCache[mangaDexId]!;
    final currentOffset = state[mangaDexId] ?? 0;
    final effectiveChapter = guard.chapterProgress + currentOffset;

    // GUARD: Completed series
    if (guard.status == ReadingStatus.completed) return false;

    // GUARD: At max chapters
    if (guard.totalChapters != null &&
        effectiveChapter >= guard.totalChapters!) {
      return false;
    }

    // Apply ephemeral offset immediately for instant UI update
    state = {...state, mangaDexId: currentOffset + 1};

    // Schedule debounced flush
    _scheduleFlush(mangaDexId);

    return true;
  }

  /// Get the effective chapter count (base + offset) for a manga.
  int getEffectiveChapter(String mangaDexId, int baseChapter) {
    return baseChapter + (state[mangaDexId] ?? 0);
  }

  void _scheduleFlush(String mangaDexId) {
    // Cancel any existing timer for this manga and create a new one
    _subscriptions[mangaDexId]?.cancel();

    _subscriptions[mangaDexId] = Stream.value(mangaDexId)
        .delay(const Duration(milliseconds: 800))
        .listen((_) => _flushToIsar(mangaDexId));
  }

  Future<void> _flushToIsar(String mangaDexId) async {
    final pendingCount = state[mangaDexId];
    if (pendingCount == null || pendingCount <= 0) return;

    // Clear offset BEFORE writing to prevent double-counting
    // when Isar stream emits the updated data
    state = Map.from(state)..remove(mangaDexId);

    // Also clear guard cache so next tap gets fresh data
    _guardCache.remove(mangaDexId);

    // Clean up subscription
    _subscriptions.remove(mangaDexId);

    final isarService = _ref.read(isarServiceProvider);

    // Batch write: increment N times in a single call
    for (int i = 0; i < pendingCount; i++) {
      await isarService.incrementChapter(mangaDexId);
    }

    // Fire and forget widget update
    try {
      _ref.read(widgetServiceProvider).updateWidgetData().ignore();
    } catch (_) {
      // Provider may not be available in all contexts
    }
  }

  /// Force-flush all pending offsets immediately (e.g., on app pause).
  Future<void> flushAll() async {
    final entries = Map<String, int>.from(state);
    for (final entry in entries.entries) {
      await _flushToIsar(entry.key);
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _flushSubject.close();
    super.dispose();
  }
}

/// Cached guard data to avoid repeated Isar lookups during rapid tapping.
class _MangaGuardData {
  final ReadingStatus status;
  final int chapterProgress;
  final int? totalChapters;

  const _MangaGuardData({
    required this.status,
    required this.chapterProgress,
    required this.totalChapters,
  });
}

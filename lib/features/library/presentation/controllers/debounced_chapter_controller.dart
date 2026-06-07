import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/core/native/widget_service.dart';

/// Chapter actions backed directly by Isar.
final chapterOffsetProvider =
    StateNotifierProvider<ChapterOffsetNotifier, Map<String, int>>((ref) {
      return ChapterOffsetNotifier(ref);
    });

class ChapterOffsetNotifier extends StateNotifier<Map<String, int>> {
  final Ref _ref;

  ChapterOffsetNotifier(this._ref) : super({});

  /// Increment the persisted chapter count for a manga by 1.
  ///
  /// The UI must read updates from the Isar watch stream instead of this
  /// notifier, avoiding optimistic Riverpod state during database writes.
  Future<bool> increment(String mangaDexId) async {
    final isarService = _ref.read(isarServiceProvider);
    final result = await isarService.incrementChapter(mangaDexId);
    if (result) {
      try {
        _ref.read(widgetServiceProvider).updateWidgetData().ignore();
      } catch (_) {
        // Provider may not be available in all contexts.
      }
    }
    return result;
  }

  /// Returns the persisted chapter count. Kept for compatibility with older
  /// callers that used to ask this notifier for an optimistic offset.
  int getEffectiveChapter(String mangaDexId, int baseChapter) {
    return baseChapter;
  }

  /// No-op compatibility hook; there is no pending optimistic state to flush.
  Future<void> flushAll() async {}
}

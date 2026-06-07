import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/data/models/reading_log.dart';

/// Provider for the IsarService singleton instance.
///
/// Usage:
/// ```dart
/// final isarService = ref.watch(isarServiceProvider);
/// await isarService.saveManga(manga);
/// ```
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

/// Future provider that initializes the database.
/// Watch this in your app startup to ensure DB is ready.
final isarInitProvider = FutureProvider<Isar>((ref) async {
  final service = ref.watch(isarServiceProvider);
  return service.openDB();
});

/// Service class for all Isar database operations.
///
/// This class provides a clean, typed API for CRUD operations on manga items.
/// It follows the repository pattern, abstracting away Isar-specific details
/// from the rest of the application.
class IsarService {
  static Isar? _isar;

  /// Opens or returns the existing Isar database instance.
  ///
  /// Uses lazy initialization - the database is only opened once and cached.
  /// Stores data in the application documents directory for persistence.
  Future<Isar> openDB() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [MangaItemSchema, ReadingLogSchema],
      directory: dir.path,
      name: 'storysync_db',
    );

    return _isar!;
  }

  /// Returns the current Isar instance, opening the DB if necessary.
  Future<Isar> get _db async => await openDB();

  // ============================================================
  // CRUD Operations
  // ============================================================

  /// Saves a manga item to the database.
  ///
  /// If a manga with the same [mangaDexId] already exists, it will be replaced
  /// due to the `replace: true` index configuration.
  ///
  /// Returns the ID of the saved item.
  Future<int> saveManga(MangaItem item) async {
    final isar = await _db;
    item.lastUpdated = DateTime.now();

    return isar.writeTxn(() async {
      return isar.mangaItems.put(item);
    });
  }

  /// Saves multiple manga items in a single transaction.
  ///
  /// More efficient than calling [saveManga] multiple times.
  Future<List<int>> saveMangaList(List<MangaItem> items) async {
    final isar = await _db;
    final now = DateTime.now();

    for (final item in items) {
      item.lastUpdated = now;
    }

    return isar.writeTxn(() async {
      return isar.mangaItems.putAll(items);
    });
  }

  /// Retrieves all manga items from the database.
  ///
  /// Returns items sorted by [lastUpdated] in descending order (most recent first).
  Future<List<MangaItem>> getAllManga() async {
    final isar = await _db;
    return isar.mangaItems.where().sortByLastUpdatedDesc().findAll();
  }

  /// Retrieves manga items filtered by reading status.
  ///
  /// Useful for displaying category-specific lists in the library.
  Future<List<MangaItem>> getMangaByStatus(ReadingStatus status) async {
    final isar = await _db;
    return isar.mangaItems
        .filter()
        .readingStatusEqualTo(status)
        .sortByLastUpdatedDesc()
        .findAll();
  }

  /// Retrieves a single manga item by its MangaDex ID.
  ///
  /// Returns null if no item with the given ID exists.
  Future<MangaItem?> getMangaByMangaDexId(String mangaDexId) async {
    final isar = await _db;
    return isar.mangaItems.filter().mangaDexIdEqualTo(mangaDexId).findFirst();
  }

  /// Increments the chapter progress of a manga by 1.
  ///
  /// Returns `true` if the operation was successful, `false` if the manga
  /// was not found.
  ///
  /// Respects [totalChapters] if set - won't increment beyond total.
  Future<bool> incrementChapter(
    String mangaDexId, {
    bool isPastReading = false,
  }) async {
    final isar = await _db;

    return isar.writeTxn(() async {
      final manga = await isar.mangaItems
          .filter()
          .mangaDexIdEqualTo(mangaDexId)
          .findFirst();

      if (manga == null) return false;

      // GUARD: Prevent increment on completed series — no ReadingLog should
      // be created for a series the user has already finished.
      if (manga.readingStatus == ReadingStatus.completed) {
        return false;
      }

      // Don't increment beyond total chapters if known
      if (manga.totalChapters != null &&
          manga.chapterProgress >= manga.totalChapters!) {
        return false;
      }

      manga.chapterProgress++;
      manga.lastUpdated = DateTime.now();
      manga.lastReadAt = DateTime.now();

      await isar.mangaItems.put(manga);

      if (!isPastReading) {
        final today = DateTime.now();
        final logDate = DateTime(today.year, today.month, today.day);

        var log = await isar.readingLogs
            .filter()
            .dateEqualTo(logDate)
            .mangaDexIdEqualTo(mangaDexId)
            .findFirst();

        if (log == null) {
          log = ReadingLog.create(
            date: logDate,
            mangaDexId: mangaDexId,
            chaptersRead: 1,
            exactTimestamp: DateTime.now(),
          );
        } else {
          log.chaptersRead++;
          log.exactTimestamp = DateTime.now();
        }

        await isar.readingLogs.put(log);
      }
      return true;
    });
  }

  /// Decrements the chapter progress of a manga by 1.
  ///
  /// Returns `true` if the operation was successful, `false` if the manga
  /// was not found or chapter is already at 0.
  Future<bool> decrementChapter(String mangaDexId) async {
    final isar = await _db;
    final manga = await getMangaByMangaDexId(mangaDexId);

    if (manga == null || manga.chapterProgress <= 0) return false;

    manga.chapterProgress--;
    manga.lastUpdated = DateTime.now();

    await isar.writeTxn(() async {
      await isar.mangaItems.put(manga);
    });

    return true;
  }

  /// Updates the reading status of a manga.
  ///
  /// Returns `true` if successful, `false` if manga not found.
  ///
  /// When status is set to [ReadingStatus.completed], automatically sets
  /// [chapterProgress] to [totalChapters] if [totalChapters] is known.
  Future<bool> updateStatus(String mangaDexId, ReadingStatus status) async {
    final isar = await _db;
    final manga = await getMangaByMangaDexId(mangaDexId);

    if (manga == null) return false;

    manga.readingStatus = status;

    if (status == ReadingStatus.completed && manga.totalChapters != null) {
      manga.chapterProgress = manga.totalChapters!;
    }

    manga.lastUpdated = DateTime.now();

    await isar.writeTxn(() async {
      await isar.mangaItems.put(manga);
    });

    return true;
  }

  /// Deletes a manga item by its MangaDex ID.
  ///
  /// Returns `true` if the item was deleted, `false` if it didn't exist.
  Future<bool> deleteManga(String mangaDexId) async {
    final isar = await _db;
    final manga = await getMangaByMangaDexId(mangaDexId);

    if (manga == null) return false;

    return isar.writeTxn(() async {
      return isar.mangaItems.delete(manga.id);
    });
  }

  /// Returns the count of [ReadingLog] entries for a given manga.
  ///
  /// Used by the delete guard dialog to determine if orphaned logs exist.
  Future<int> getReadingLogCountForManga(String mangaDexId) async {
    final isar = await _db;
    return isar.readingLogs.filter().mangaDexIdEqualTo(mangaDexId).count();
  }

  /// Atomically deletes a manga AND all its associated reading logs.
  ///
  /// Prevents orphaned `ReadingLog` entries that would show as
  /// "Unknown Title" in the Insights heatmap.
  /// Returns `true` if the manga was found and deleted.
  Future<bool> deleteMangaWithCascade(String mangaDexId) async {
    final isar = await _db;
    final manga = await getMangaByMangaDexId(mangaDexId);

    if (manga == null) return false;

    return isar.writeTxn(() async {
      // Cascade-delete all reading logs for this title
      await isar.readingLogs.filter().mangaDexIdEqualTo(mangaDexId).deleteAll();
      // Then delete the manga item itself
      return isar.mangaItems.delete(manga.id);
    });
  }

  /// Deletes all manga items from the database.
  ///
  /// Use with caution - this is destructive and cannot be undone.
  Future<void> clearAll() async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.mangaItems.clear();
    });
  }

  /// Returns the total count of manga items in the library.
  Future<int> getCount() async {
    final isar = await _db;
    return isar.mangaItems.count();
  }

  /// Checks if a manga with the given MangaDex ID exists in the library.
  Future<bool> exists(String mangaDexId) async {
    final manga = await getMangaByMangaDexId(mangaDexId);
    return manga != null;
  }

  /// Watches all manga items for changes.
  ///
  /// Returns a stream that emits whenever the manga collection changes.
  /// Useful for reactive UI updates.
  Stream<List<MangaItem>> watchAllManga() async* {
    final isar = await _db;
    yield* isar.mangaItems.where().sortByLastUpdatedDesc().watch(
      fireImmediately: true,
    );
  }

  /// Watches manga items filtered by status for changes.
  Stream<List<MangaItem>> watchMangaByStatus(ReadingStatus status) async* {
    final isar = await _db;
    yield* isar.mangaItems
        .filter()
        .readingStatusEqualTo(status)
        .sortByLastUpdatedDesc()
        .watch(fireImmediately: true);
  }

  /// Watches a single manga item by its MangaDex ID.
  Stream<MangaItem?> watchMangaByMangaDexId(String mangaDexId) async* {
    final isar = await _db;
    yield* isar.mangaItems
        .filter()
        .mangaDexIdEqualTo(mangaDexId)
        .watch(fireImmediately: true)
        .map((items) => items.isEmpty ? null : items.first);
  }

  /// Watches all reading logs for changes.
  ///
  /// Returns a stream that emits whenever the reading log collection changes.
  /// Used by the Insights tab for reactive analytics updates.
  Stream<List<ReadingLog>> watchAllReadingLogs() async* {
    final isar = await _db;
    yield* isar.readingLogs.where().watch(fireImmediately: true);
  }

  /// Gets the DB directory path (Isolates cannot easily use path_provider)
  Future<String> getDbDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Acts as a doorbell for Manga changes (no data payload)
  Stream<void> watchMangaChanges() async* {
    final isar = await _db;
    yield* isar.mangaItems.watchLazy(fireImmediately: true);
  }

  /// Acts as a doorbell for ReadingLog changes (no data payload)
  Stream<void> watchReadingLogChanges() async* {
    final isar = await _db;
    yield* isar.readingLogs.watchLazy(fireImmediately: true);
  }

  // ============================================================
  // Reading Log Operations
  // ============================================================

  /// Logs a chapter read for today.
  ///
  /// **Deprecated:** Use [incrementChapter] instead, which provides the
  /// [isPastReading] guard to prevent historical bulk imports from
  /// polluting the analytics heatmap.
  @Deprecated('Use incrementChapter() which has the isPastReading guard')
  Future<void> logChapterRead(
    String mangaDexId, {
    bool isImport = false,
  }) async {
    final isar = await _db;
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    final existingLogs = await isar.readingLogs
        .filter()
        .dateEqualTo(normalizedDate)
        .mangaDexIdEqualTo(mangaDexId)
        .findFirst();

    if (existingLogs != null) {
      existingLogs.chaptersRead++;
      await isar.writeTxn(() async {
        await isar.readingLogs.put(existingLogs);
      });
    } else {
      final newLog = ReadingLog.create(
        date: normalizedDate,
        mangaDexId: mangaDexId,
        chaptersRead: 1,
        isImported: isImport,
      );
      await isar.writeTxn(() async {
        await isar.readingLogs.put(newLog);
      });
    }
  }

  /// Gets today's chapter count for a specific manga.
  Future<int> getTodayChapterCount(String mangaDexId) async {
    final isar = await _db;
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    final log = await isar.readingLogs
        .filter()
        .dateEqualTo(normalizedDate)
        .mangaDexIdEqualTo(mangaDexId)
        .findFirst();

    return log?.chaptersRead ?? 0;
  }

  /// Gets all reading logs for a date range.
  Future<List<ReadingLog>> getReadingLogsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final isar = await _db;
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    return isar.readingLogs
        .filter()
        .dateBetween(normalizedStart, normalizedEnd)
        .findAll();
  }

  /// Gets all reading logs.
  Future<List<ReadingLog>> getAllReadingLogs() async {
    final isar = await _db;
    return isar.readingLogs.where().findAll();
  }

  /// Saves a reading log (used during import). Marks as imported.
  Future<void> saveReadingLog(ReadingLog log) async {
    log.isImported = true;
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.readingLogs.put(log);
    });
  }

  /// Saves multiple reading logs (used during import). Marks all as imported.
  Future<void> saveReadingLogs(List<ReadingLog> logs) async {
    for (final log in logs) {
      log.isImported = true;
    }
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.readingLogs.putAll(logs);
    });
  }

  /// Restores a reading log preserving its original flags.
  ///
  /// Unlike [saveReadingLog], this does NOT override `isImported` or
  /// `isPastReading`. Used during JSON backup restore so analytics
  /// mirrors the original state exactly.
  Future<void> restoreReadingLog(ReadingLog log) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.readingLogs.put(log);
    });
  }

  /// Validates and restores reading logs with referential integrity.
  ///
  /// Only imports logs whose [mangaDexId] exists in the provided
  /// [mangaDexIdMap]. Preserves original `isImported`/`isPastReading`
  /// flags so analytics are identical post-restore.
  ///
  /// Returns the count of successfully restored logs.
  Future<int> restoreReadingLogsWithIntegrity(
    List<ReadingLog> logs,
    Set<String> validMangaDexIds,
  ) async {
    final isar = await _db;
    int count = 0;
    final validLogs = logs
        .where((log) => validMangaDexIds.contains(log.mangaDexId))
        .toList();

    if (validLogs.isEmpty) return 0;

    await isar.writeTxn(() async {
      await isar.readingLogs.putAll(validLogs);
      count = validLogs.length;
    });
    return count;
  }

  /// Gets all reading logs for a specific date (for heatmap day-detail).
  Future<List<ReadingLog>> getLogsForDate(DateTime date) async {
    final isar = await _db;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return isar.readingLogs.filter().dateEqualTo(normalizedDate).findAll();
  }

  /// Clears all reading logs.
  Future<void> clearReadingLogs() async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.readingLogs.clear();
    });
  }

  /// Closes the database connection.
  ///
  /// Call this when the app is being disposed to clean up resources.
  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _isar = null;
    }
  }
}

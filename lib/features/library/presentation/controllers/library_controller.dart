import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/features/discover/data/services/mangadex_service.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';

part 'library_controller.g.dart';

/// Controller for the Library feature.
///
/// Provides a reactive stream of manga items from the local Isar database
/// and exposes methods for CRUD operations.
@riverpod
class LibraryController extends _$LibraryController {
  IsarService get _isarService => ref.read(isarServiceProvider);

  @override
  Stream<List<MangaItem>> build() {
    return _isarService.watchAllManga();
  }

  /// Adds a manga item to the library.
  ///
  /// If a manga with the same mangaDexId already exists, it will be updated.
  Future<void> addManga(MangaItem item) async {
    await _isarService.saveManga(item);
  }

  /// Increments the chapter progress of a manga by 1.
  ///
  /// Returns `true` if successful, `false` if manga not found or at max.
  Future<bool> incrementChapter(String mangaDexId) async {
    return _isarService.incrementChapter(mangaDexId);
  }

  /// Decrements the chapter progress of a manga by 1.
  ///
  /// Returns `true` if successful, `false` if manga not found or at 0.
  Future<bool> decrementChapter(String mangaDexId) async {
    return _isarService.decrementChapter(mangaDexId);
  }

  /// Updates the reading status of a manga.
  ///
  /// Returns `true` if successful, `false` if manga not found.
  Future<bool> updateStatus(String mangaDexId, ReadingStatus status) async {
    return _isarService.updateStatus(mangaDexId, status);
  }

  /// Removes a manga from the library.
  ///
  /// Returns `true` if successfully deleted, `false` if not found.
  Future<bool> removeManga(String mangaDexId) async {
    return _isarService.deleteManga(mangaDexId);
  }

  /// Checks if a manga exists in the library.
  Future<bool> exists(String mangaDexId) async {
    return _isarService.exists(mangaDexId);
  }

  /// Gets a single manga by its MangaDex ID.
  Future<MangaItem?> getManga(String mangaDexId) async {
    return _isarService.getMangaByMangaDexId(mangaDexId);
  }

  /// Refreshes metadata (title, author, cover, synopsis) for all library items from MangaDex.
  ///
  /// This is useful for updating titles to English or fixing outdated metadata.
  /// Returns the number of successfully updated items.
  Future<int> refreshAllMetadata() async {
    final mangaDexService = ref.read(mangaDexServiceProvider);
    final allManga = await _isarService.getAllManga();
    int successCount = 0;

    for (final manga in allManga) {
      try {
        // Fetch fresh data from MangaDex
        final freshData = await mangaDexService.getMangaDetails(
          manga.mangaDexId,
        );

        // Preserve user's tracking data, only update metadata
        manga.title = freshData.title;
        manga.author = freshData.author;
        manga.coverUrl = freshData.coverUrl;
        manga.synopsis = freshData.synopsis;
        manga.totalChapters = freshData.totalChapters ?? manga.totalChapters;

        // Save updated manga
        await _isarService.saveManga(manga);
        successCount++;
      } catch (e) {
        // Skip this manga if fetch fails, continue with others
        continue;
      }
    }

    return successCount;
  }
}

/// StreamProvider that watches manga filtered by a specific reading status.
///
/// Usage:
/// ```dart
/// final readingManga = ref.watch(libraryByStatusProvider(ReadingStatus.reading));
/// ```
@riverpod
Stream<List<MangaItem>> libraryByStatus(
  LibraryByStatusRef ref,
  ReadingStatus status,
) {
  final isarService = ref.watch(isarServiceProvider);
  return isarService.watchMangaByStatus(status);
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storysync/features/discover/data/services/mangadex_service.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';

part 'discover_controller.g.dart';

/// Controller for the Discover/Search feature.
///
/// Manages search state and communicates with the MangaDex API
/// to fetch manga search results.
@riverpod
class DiscoverController extends _$DiscoverController {
  MangaDexService get _mangaDexService => ref.read(mangaDexServiceProvider);

  @override
  FutureOr<List<MangaItem>> build() {
    // Initial state is an empty list (no search performed yet)
    return <MangaItem>[];
  }

  /// Searches for manga by title.
  ///
  /// Sets state to loading while fetching, then updates with results
  /// or error state.
  Future<void> search(String query, {bool isRefresh = false}) async {
    if (query.trim().isEmpty) {
      state = const AsyncData(<MangaItem>[]);
      return;
    }

    // Only set loading state if not refreshing (to avoid breaking RefreshIndicator)
    if (!isRefresh) {
      state = const AsyncLoading();
    }

    // Perform search
    state = await AsyncValue.guard(() async {
      return _mangaDexService.searchManga(query, fetchChapterCounts: true);
    });
  }

  /// Clears the search results.
  void clearResults() {
    state = const AsyncData(<MangaItem>[]);
  }

  /// Fetches detailed information for a specific manga.
  ///
  /// Returns the manga details or throws a [MangaDexException].
  Future<MangaItem> getMangaDetails(String mangaDexId) async {
    return _mangaDexService.getMangaDetails(mangaDexId);
  }

  /// Fetches the total chapter count for a manga.
  ///
  /// Returns null if the count cannot be determined.
  Future<int?> getChapterCount(String mangaDexId) async {
    return _mangaDexService.getChapterCount(mangaDexId);
  }

  /// Updates a manga in the current results list.
  ///
  /// Used when the user edits manga information.
  void updateManga(String mangaDexId, MangaItem updatedManga) {
    state.whenData((mangaList) {
      final updatedList = mangaList.map((manga) {
        if (manga.mangaDexId == mangaDexId) {
          return updatedManga;
        }
        return manga;
      }).toList();
      state = AsyncData(updatedList);
    });
  }
}

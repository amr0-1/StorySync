import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/core/network/dio_client.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';

/// Base URL for MangaDex cover image uploads
const String _coverBaseUrl = 'https://uploads.mangadex.org/covers';

/// Provider for the MangaDex API service.
///
/// This service handles all interactions with the MangaDex API.
///
/// Usage:
/// ```dart
/// final mangaDexService = ref.watch(mangaDexServiceProvider);
/// final results = await mangaDexService.searchManga('One Piece');
/// ```
final mangaDexServiceProvider = Provider<MangaDexService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return MangaDexService(dio);
});

/// Service class for interacting with the MangaDex API.
///
/// Handles searching, fetching manga details, and mapping responses
/// to our local [MangaItem] model.
class MangaDexService {
  final Dio _dio;

  MangaDexService(this._dio);

  /// Searches for manga by title.
  ///
  /// Returns a list of [MangaItem] objects ready for persistence or display.
  ///
  /// The [query] parameter is the search term.
  /// Optional [limit] parameter controls the number of results (default: 20, max: 100).
  /// Optional [fetchChapterCounts] fetches chapter counts for each result (slower, default: false).
  ///
  /// Example:
  /// ```dart
  /// final results = await service.searchManga('Solo Leveling');
  /// ```
  Future<List<MangaItem>> searchManga(
    String query, {
    int limit = 20,
    bool fetchChapterCounts = false,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/manga',
        queryParameters: {
          'title': query,
          'limit': limit.clamp(1, 100),
          'includes[]': [
            'cover_art',
            'author',
          ], // Include cover art and author relationships
          'order[relevance]': 'desc',
          'contentRating[]': [
            'safe',
            'suggestive',
          ], // Filter out explicit content
        },
      );

      if (response.statusCode != 200) {
        throw MangaDexException(
          'Search failed with status ${response.statusCode}',
        );
      }

      final data = response.data as Map<String, dynamic>;
      final mangaList = data['data'] as List<dynamic>? ?? [];

      final items = mangaList.map((json) => _mapToMangaItem(json)).toList();

      // Optionally fetch chapter counts for each manga
      if (fetchChapterCounts) {
        await Future.wait(
          items.map((item) async {
            final chapters = await getChapterCount(item.mangaDexId);
            item.totalChapters = chapters;
          }),
        );
      }

      return items;
    } on DioException catch (e) {
      throw MangaDexException(e.userMessage);
    } catch (e) {
      if (e is MangaDexException) rethrow;
      throw MangaDexException('Failed to search manga: $e');
    }
  }

  /// Fetches detailed information for a specific manga by its MangaDex ID.
  ///
  /// Returns a [MangaItem] with full details including synopsis and chapter count.
  Future<MangaItem> getMangaDetails(String mangaDexId) async {
    try {
      final response = await _dio.get(
        '/manga/$mangaDexId',
        queryParameters: {
          'includes[]': ['cover_art', 'author'],
        },
      );

      if (response.statusCode != 200) {
        throw MangaDexException('Failed to fetch manga details');
      }

      final data = response.data as Map<String, dynamic>;
      final mangaData = data['data'] as Map<String, dynamic>;

      final mangaItem = _mapToMangaItem(mangaData);

      // Fetch chapter count
      final chapterCount = await getChapterCount(mangaDexId);
      mangaItem.totalChapters = chapterCount;

      return mangaItem;
    } on DioException catch (e) {
      throw MangaDexException(e.userMessage);
    } catch (e) {
      if (e is MangaDexException) rethrow;
      throw MangaDexException('Failed to fetch manga details: $e');
    }
  }

  /// Fetches aggregate chapter information for a manga.
  ///
  /// Returns the total number of chapters if available.
  Future<int?> getChapterCount(String mangaDexId) async {
    try {
      debugPrint('Fetching chapter count for manga: $mangaDexId');
      // Don't filter by language to get total chapter count regardless of translation
      final response = await _dio.get('/manga/$mangaDexId/aggregate');

      if (response.statusCode != 200) {
        debugPrint(
          'Chapter count fetch failed with status ${response.statusCode} for $mangaDexId',
        );
        return null;
      }

      final data = response.data as Map<String, dynamic>;
      debugPrint('Aggregate response data keys: ${data.keys}');

      final volumes = data['volumes'] as Map<String, dynamic>? ?? {};
      debugPrint('Found ${volumes.length} volumes for manga $mangaDexId');

      if (volumes.isEmpty) {
        debugPrint('No volumes found in aggregate data for manga $mangaDexId');
        return null;
      }

      // Count unique chapters across all volumes
      final chapters = <String>{};
      for (final volumeEntry in volumes.entries) {
        final volumeKey = volumeEntry.key;
        final volumeData = volumeEntry.value;

        if (volumeData is Map<String, dynamic>) {
          final volumeChapters =
              volumeData['chapters'] as Map<String, dynamic>? ?? {};
          if (volumeChapters.isNotEmpty) {
            debugPrint('  Volume $volumeKey has ${volumeChapters.length} chapters');
          }
          chapters.addAll(volumeChapters.keys);
        }
      }

      if (chapters.isEmpty) {
        debugPrint('No chapters found in any volume for manga $mangaDexId');
        return null;
      }

      debugPrint(
        'Successfully fetched ${chapters.length} total unique chapters for manga $mangaDexId',
      );
      return chapters.length;
    } catch (e, stackTrace) {
      // Log detailed error information
      debugPrint('Error fetching chapter count for $mangaDexId: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Maps a MangaDex API manga object to our local [MangaItem] model.
  MangaItem _mapToMangaItem(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    final relationships = json['relationships'] as List<dynamic>? ?? [];

    // Extract title (prefer English, fallback to other languages)
    final title = _extractTitle(attributes);

    // Extract description/synopsis (prefer English)
    final synopsis = _extractDescription(attributes);

    // Extract author name from relationships
    final author = _extractAuthor(relationships);

    // Extract cover URL from relationships
    final coverUrl = _extractCoverUrl(id, relationships);

    return MangaItem.create(
      mangaDexId: id,
      title: title,
      author: author,
      coverUrl: coverUrl,
      synopsis: synopsis,
      readingStatus: ReadingStatus.planToRead,
      chapterProgress: 0,
    );
  }

  /// Extracts the best available title from manga attributes.
  ///
  /// Priority: English > Japanese romanized > English from altTitles > Japanese > non-Korean first available
  String _extractTitle(Map<String, dynamic> attributes) {
    final title = attributes['title'] as Map<String, dynamic>? ?? {};

    // Try English first
    if (title['en'] != null) return title['en'] as String;

    // Try Japanese romanized
    if (title['ja-ro'] != null) return title['ja-ro'] as String;

    // Check alt titles for English before falling back to other languages
    final altTitles = attributes['altTitles'] as List<dynamic>? ?? [];
    for (final alt in altTitles) {
      if (alt is Map<String, dynamic> && alt['en'] != null) {
        return alt['en'] as String;
      }
    }

    // Try Japanese
    if (title['ja'] != null) return title['ja'] as String;

    // Return first available non-Korean title
    for (final entry in title.entries) {
      if (entry.key != 'ko' && entry.value != null) {
        return entry.value as String;
      }
    }

    // If only Korean title is available, use it as last resort
    if (title['ko'] != null) return title['ko'] as String;

    // Final fallback to alt titles (non-Korean preferred)
    for (final alt in altTitles) {
      if (alt is Map<String, dynamic>) {
        for (final entry in alt.entries) {
          if (entry.key != 'ko' && entry.value != null) {
            return entry.value as String;
          }
        }
      }
    }

    return 'Unknown Title';
  }

  /// Extracts the best available description from manga attributes.
  ///
  /// Priority: English > first available > null
  String? _extractDescription(Map<String, dynamic> attributes) {
    final description =
        attributes['description'] as Map<String, dynamic>? ?? {};

    // Try English first
    if (description['en'] != null) {
      return description['en'] as String;
    }

    // Return first available description
    if (description.isNotEmpty) {
      return description.values.first as String;
    }

    return null;
  }

  /// Extracts the cover image URL from manga relationships.
  ///
  /// Finds the cover_art relationship and constructs the full URL
  /// using the MangaDex uploads endpoint.
  String? _extractCoverUrl(String mangaId, List<dynamic> relationships) {
    for (final rel in relationships) {
      if (rel is Map<String, dynamic> && rel['type'] == 'cover_art') {
        final attributes = rel['attributes'] as Map<String, dynamic>?;
        if (attributes != null) {
          final fileName = attributes['fileName'] as String?;
          if (fileName != null) {
            // Construct full cover URL
            // Format: https://uploads.mangadex.org/covers/{mangaId}/{fileName}
            return '$_coverBaseUrl/$mangaId/$fileName';
          }
        }
      }
    }
    return null;
  }

  /// Extracts the author name from manga relationships.
  ///
  /// Finds the author relationship and returns the author's name.
  String? _extractAuthor(List<dynamic> relationships) {
    for (final rel in relationships) {
      if (rel is Map<String, dynamic> && rel['type'] == 'author') {
        final attributes = rel['attributes'] as Map<String, dynamic>?;
        if (attributes != null) {
          final name = attributes['name'] as String?;
          if (name != null) {
            return name;
          }
        }
      }
    }
    return null;
  }
}

/// Custom exception for MangaDex API errors.
///
/// Provides user-friendly error messages for display in the UI.
class MangaDexException implements Exception {
  final String message;

  MangaDexException(this.message);

  @override
  String toString() => message;
}

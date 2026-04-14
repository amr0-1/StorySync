import 'package:isar/isar.dart';
import 'package:storysync/core/models/reading_status.dart';

export 'package:storysync/core/models/reading_status.dart';

part 'manga_item.g.dart';

/// Isar collection for persisting manga tracking data locally.
///
/// This is the single source of truth for all library data.
/// The [mangaDexId] serves as the external identifier linking to MangaDex API.
@collection
class MangaItem {
  /// Auto-incrementing primary key for Isar
  Id id = Isar.autoIncrement;

  /// MangaDex UUID - unique external identifier
  /// Using replace: true allows upsert behavior on conflicts
  @Index(unique: true, replace: true)
  late String mangaDexId;

  /// Manga title (from MangaDex or user-provided)
  late String title;

  /// Author name (from MangaDex)
  String? author;

  /// Full cover image URL (constructed from MangaDex covers endpoint)
  String? coverUrl;

  /// Synopsis/description of the manga
  String? synopsis;

  /// Current reading status
  @enumerated
  ReadingStatus readingStatus = ReadingStatus.planToRead;

  /// Current chapter progress (0-indexed chapter the user has read up to)
  int chapterProgress = 0;

  /// Total number of chapters (null if ongoing/unknown)
  int? totalChapters;

  /// The source of this tracking entry (e.g. 'mangadex', 'manual')
  String source = 'mangadex';

  /// Whether the user has manually edited the metadata (title, author, etc.)
  bool hasCustomMetadata = false;

  /// Timestamp of last update to this record
  DateTime lastUpdated = DateTime.now();


  /// Default constructor
  MangaItem();

  /// Named constructor for creating a new manga item
  MangaItem.create({
    required this.mangaDexId,
    required this.title,
    this.author,
    this.coverUrl,
    this.synopsis,
    this.readingStatus = ReadingStatus.planToRead,
    this.chapterProgress = 0,
    this.totalChapters,
    this.source = 'mangadex',
    this.hasCustomMetadata = false,
  }) : lastUpdated = DateTime.now();


  /// Calculate reading progress as percentage (0.0 to 1.0)
  double get progress {
    if (totalChapters == null || totalChapters == 0) return 0.0;
    return (chapterProgress / totalChapters!).clamp(0.0, 1.0);
  }

  /// Calculate remaining chapters
  int get remainingChapters {
    if (totalChapters == null) return 0;
    return (totalChapters! - chapterProgress).clamp(0, totalChapters!);
  }

  /// Progress percentage as int (0-100)
  int get progressPercent => (progress * 100).round();

  // ============================================================
  // UI Compatibility Getters (ignored by Isar)
  // ============================================================

  /// Alias for mangaDexId - used by UI components
  @ignore
  String get uid => mangaDexId;

  /// Alias for readingStatus - used by UI components
  @ignore
  ReadingStatus get status => readingStatus;

  /// Alias for chapterProgress - used by UI components
  @ignore
  int get currentChapter => chapterProgress;

  Map<String, dynamic> toJson() {
    return {
      'mangaDexId': mangaDexId,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'synopsis': synopsis,
      'readingStatus': readingStatus.name,
      'chapterProgress': chapterProgress,
      'totalChapters': totalChapters,
      'source': source,
      'hasCustomMetadata': hasCustomMetadata,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory MangaItem.fromJson(Map<String, dynamic> json) {
    return MangaItem.create(
      mangaDexId: json['mangaDexId'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      coverUrl: json['coverUrl'] as String?,
      synopsis: json['synopsis'] as String?,
      readingStatus: ReadingStatus.values.firstWhere(
        (e) => e.name == json['readingStatus'],
        orElse: () => ReadingStatus.planToRead,
      ),
      chapterProgress: json['chapterProgress'] as int? ?? 0,
      totalChapters: json['totalChapters'] as int?,
      source: json['source'] as String? ?? 'mangadex',
      hasCustomMetadata: json['hasCustomMetadata'] as bool? ?? false,
    )..lastUpdated = json['lastUpdated'] != null 
        ? DateTime.parse(json['lastUpdated'] as String) 
        : DateTime.now();
  }

  @override
  String toString() =>
      'MangaItem(id: $id, title: $title, progress: $chapterProgress/$totalChapters)';

}

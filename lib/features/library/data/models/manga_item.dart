import 'package:isar/isar.dart';

part 'manga_item.g.dart';

/// Reading status for tracking manga progress in Isar database
enum ReadingStatus {
  reading,
  completed,
  onHold,
  planToRead,
  dropped;

  /// Display label for UI
  String get displayLabel => switch (this) {
    ReadingStatus.reading => 'Reading',
    ReadingStatus.completed => 'Completed',
    ReadingStatus.onHold => 'On Hold',
    ReadingStatus.planToRead => 'Plan to Read',
    ReadingStatus.dropped => 'Dropped',
  };

  /// Short label for compact badges
  String get shortLabel => switch (this) {
    ReadingStatus.reading => 'Reading',
    ReadingStatus.completed => 'Done',
    ReadingStatus.onHold => 'Hold',
    ReadingStatus.planToRead => 'PTR',
    ReadingStatus.dropped => 'Dropped',
  };
}

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

  /// Timestamp of last update to this record
  DateTime lastUpdated = DateTime.now();

  /// Default constructor
  MangaItem();

  /// Named constructor for creating a new manga item
  MangaItem.create({
    required this.mangaDexId,
    required this.title,
    this.coverUrl,
    this.synopsis,
    this.readingStatus = ReadingStatus.planToRead,
    this.chapterProgress = 0,
    this.totalChapters,
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

  @override
  String toString() =>
      'MangaItem(id: $id, title: $title, progress: $chapterProgress/$totalChapters)';
}

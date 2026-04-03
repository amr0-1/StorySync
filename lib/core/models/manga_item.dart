import 'package:mtrack/core/models/reading_status.dart';

/// Manga item model for library tracking
/// This is a simple model for UI purposes. For Isar persistence,
/// this would need @Collection annotation and code generation.
class MangaItem {
  final String id;
  final String title;
  final String? author;
  final String? coverUrl;
  final String? synopsis;
  final String? demographic;
  final String? publicationStatus;
  final ReadingStatus status;
  final int currentChapter;
  final int? totalChapters;
  final DateTime? lastUpdated;

  const MangaItem({
    required this.id,
    required this.title,
    this.author,
    this.coverUrl,
    this.synopsis,
    this.demographic,
    this.publicationStatus,
    this.status = ReadingStatus.planToRead,
    this.currentChapter = 0,
    this.totalChapters,
    this.lastUpdated,
  });

  /// Creates a copy with updated fields
  MangaItem copyWith({
    String? id,
    String? title,
    String? author,
    String? coverUrl,
    String? synopsis,
    String? demographic,
    String? publicationStatus,
    ReadingStatus? status,
    int? currentChapter,
    int? totalChapters,
    DateTime? lastUpdated,
  }) {
    return MangaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      synopsis: synopsis ?? this.synopsis,
      demographic: demographic ?? this.demographic,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      status: status ?? this.status,
      currentChapter: currentChapter ?? this.currentChapter,
      totalChapters: totalChapters ?? this.totalChapters,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Calculate reading progress as percentage (0.0 to 1.0)
  double get progress {
    if (totalChapters == null || totalChapters == 0) return 0.0;
    return (currentChapter / totalChapters!).clamp(0.0, 1.0);
  }

  /// Calculate remaining chapters
  int get remainingChapters {
    if (totalChapters == null) return 0;
    return (totalChapters! - currentChapter).clamp(0, totalChapters!);
  }

  /// Progress percentage as int (0-100)
  int get progressPercent => (progress * 100).round();
}

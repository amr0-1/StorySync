import 'package:isar/isar.dart';

part 'reading_log.g.dart';

@collection
class ReadingLog {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  /// Exact timestamp for time-of-day analytics (hour/minute precision).
  /// Falls back to `date` at 12:00 PM for legacy logs missing this field.
  DateTime? exactTimestamp;

  @Index()
  late String mangaDexId;

  late int chaptersRead;

  /// Estimated session duration in minutes. Defaults to 0 for legacy logs.
  int sessionDurationMinutes = 0;

  /// Whether this log was created via JSON import (excluded from analytics).
  bool isImported = false;

  /// Whether this log was a bulk/historical addition (excluded from analytics).
  bool isPastReading = false;

  /// Future-proofing: session grouping identifier.
  int? sessionId;

  ReadingLog();

  ReadingLog.create({
    required this.date,
    required this.mangaDexId,
    required this.chaptersRead,
    DateTime? exactTimestamp,
    this.sessionDurationMinutes = 0,
    this.isImported = false,
    this.isPastReading = false,
    this.sessionId,
  }) : exactTimestamp = exactTimestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mangaDexId': mangaDexId,
      'chaptersRead': chaptersRead,
      'exactTimestamp': exactTimestamp?.toIso8601String(),
      'sessionDurationMinutes': sessionDurationMinutes,
      'isImported': isImported,
      'isPastReading': isPastReading,
      if (sessionId != null) 'sessionId': sessionId,
    };
  }

  static ReadingLog fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);
    return ReadingLog.create(
      date: date,
      mangaDexId: json['mangaDexId'] as String,
      chaptersRead: json['chaptersRead'] as int,
      // BACKUP GUARD: Old JSONs lack exactTimestamp → fallback to date at noon
      exactTimestamp: json['exactTimestamp'] != null
          ? DateTime.parse(json['exactTimestamp'] as String)
          : DateTime(date.year, date.month, date.day, 12, 0),
      // BACKUP GUARD: Old JSONs lack sessionDurationMinutes → default 0
      sessionDurationMinutes: json['sessionDurationMinutes'] as int? ?? 0,
      isImported: json['isImported'] as bool? ?? false,
      isPastReading: json['isPastReading'] as bool? ?? false,
      sessionId: json['sessionId'] as int?,
    );
  }
}

@embedded
class ReadingLogEntry {
  late DateTime date;
  late String mangaDexId;
  late int chaptersRead;

  ReadingLogEntry();

  ReadingLogEntry.create({
    required this.date,
    required this.mangaDexId,
    required this.chaptersRead,
  });
}

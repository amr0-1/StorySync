import 'package:isar/isar.dart';

part 'reading_log.g.dart';

@collection
class ReadingLog {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  @Index()
  late String mangaDexId;

  late int chaptersRead;

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
    this.isImported = false,
    this.isPastReading = false,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mangaDexId': mangaDexId,
      'chaptersRead': chaptersRead,
      'isImported': isImported,
      'isPastReading': isPastReading,
      if (sessionId != null) 'sessionId': sessionId,
    };
  }

  static ReadingLog fromJson(Map<String, dynamic> json) {
    return ReadingLog.create(
      date: DateTime.parse(json['date'] as String),
      mangaDexId: json['mangaDexId'] as String,
      chaptersRead: json['chaptersRead'] as int,
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

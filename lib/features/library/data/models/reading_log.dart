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

  ReadingLog();

  ReadingLog.create({
    required this.date,
    required this.mangaDexId,
    required this.chaptersRead,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mangaDexId': mangaDexId,
      'chaptersRead': chaptersRead,
    };
  }

  static ReadingLog fromJson(Map<String, dynamic> json) {
    return ReadingLog.create(
      date: DateTime.parse(json['date'] as String),
      mangaDexId: json['mangaDexId'] as String,
      chaptersRead: json['chaptersRead'] as int,
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
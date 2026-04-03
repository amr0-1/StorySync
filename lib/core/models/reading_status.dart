/// Reading status for tracking manga progress
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

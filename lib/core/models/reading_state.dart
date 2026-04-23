/// Behavioral reading state for a manga series.
///
/// Computed from reading log activity — NOT persisted.
/// The controller decides the state, and the UI reacts to it implicitly.
enum ReadingState {
  /// No activity for > 14 days (only applies to "Reading" status).
  cold,

  /// Default fallback — normal reading pace.
  normal,

  /// Intense reading: ≥ 15 chapters in 24h OR ≥ 40 chapters in 3 days.
  /// Hot overrides Cold.
  hot;
}

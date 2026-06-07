import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global flag to pause all heavy stream listeners and Isar queries
/// while a background JSON restoration is running.
final isRestoringDatabaseProvider = StateProvider<bool>((ref) => false);

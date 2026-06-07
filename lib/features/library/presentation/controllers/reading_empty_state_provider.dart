import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:storysync/features/library/presentation/controllers/library_controller.dart';

/// The scenario to render when the Reading list is empty.
///
/// Sealed so the UI's switch is exhaustive — the compiler guarantees
/// every case is handled without a default branch.
sealed class ReadingEmptyScenario {
  const ReadingEmptyScenario();
}

/// Scenario A: Absolute beginner — no titles in Reading, Plan to Read, or On Hold.
/// UI should prompt the user to discover new manga.
class AbsoluteBeginner extends ReadingEmptyScenario {
  const AbsoluteBeginner();
}

/// Scenario B: User has titles in Plan to Read and/or On Hold, but nothing
/// actively being read. UI should show contextual navigation to populated lists.
class HasBacklog extends ReadingEmptyScenario {
  final bool hasPlanToRead;
  final bool hasOnHold;

  const HasBacklog({required this.hasPlanToRead, required this.hasOnHold});
}

/// Provider that determines the empty-state scenario for the Reading tab.
///
/// Watches [libraryByStatusProvider] for Plan to Read and On Hold —
/// the same reactive Isar streams already used by TabBarView children,
/// so no extra DB queries are introduced.
///
/// Returns `null` while either dependency is still loading, allowing
/// the UI to show shimmer/skeleton gracefully.
final readingEmptyScenarioProvider =
    Provider.autoDispose<ReadingEmptyScenario?>((ref) {
  final planToReadAsync =
      ref.watch(libraryByStatusProvider(ReadingStatus.planToRead));
  final onHoldAsync =
      ref.watch(libraryByStatusProvider(ReadingStatus.onHold));

  // Both must be resolved before we can determine the scenario.
  final planToReadList = planToReadAsync.valueOrNull;
  final onHoldList = onHoldAsync.valueOrNull;

  if (planToReadList == null || onHoldList == null) return null;

  final hasPlanToRead = planToReadList.isNotEmpty;
  final hasOnHold = onHoldList.isNotEmpty;

  if (!hasPlanToRead && !hasOnHold) {
    return const AbsoluteBeginner();
  }

  return HasBacklog(hasPlanToRead: hasPlanToRead, hasOnHold: hasOnHold);
});

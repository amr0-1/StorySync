import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalkthroughKeys {
  WalkthroughKeys();

  final GlobalKey addTitleKey = GlobalKey(debugLabel: 'addTitle');
  final GlobalKey quickIncrementKey = GlobalKey(debugLabel: 'quickIncrement');
  final GlobalKey analyticsHeatmapKey = GlobalKey(
    debugLabel: 'analyticsHeatmap',
  );
  final GlobalKey backupSettingsKey = GlobalKey(debugLabel: 'backupSettings');
}

final walkthroughKeysProvider = Provider((ref) => WalkthroughKeys());

void resetWalkthroughKeys(WidgetRef ref) {
  ref.invalidate(walkthroughKeysProvider);
}

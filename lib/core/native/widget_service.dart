import 'dart:convert';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';

const String _appGroupId = 'group.com.storysync.app';

const String _widgetTitleKey = 'widget_manga_title';
const String _widgetCurrentChapterKey = 'widget_current_chapter';
const String _widgetTotalChaptersKey = 'widget_total_chapters';
const String _widgetMangaIdKey = 'widget_manga_id';
const String _widgetCoverUrlKey = 'widget_cover_url';

final widgetServiceProvider = Provider<WidgetService>((ref) {
  return WidgetService();
});

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  static String? routeFromLaunchUri(Uri? uri) {
    if (uri == null) return null;

    final sanitized = uri.toString().replaceAll(RegExp(r'\s+'), '');
    final parsed = Uri.tryParse(sanitized);
    if (parsed == null || parsed.scheme != 'storysync') return null;

    if (parsed.host == 'manga') {
      final mangaId = parsed.pathSegments.isNotEmpty
          ? parsed.pathSegments.first
          : null;
      if (mangaId == null || mangaId.isEmpty) return null;
      return '/details/${Uri.encodeComponent(mangaId)}';
    }

    if (parsed.host == 'insights') {
      final date = parsed.queryParameters['date'];
      return Uri(
        path: '/insights',
        queryParameters: date == null || date.isEmpty ? null : {'date': date},
      ).toString();
    }

    return null;
  }

  Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      await HomeWidget.registerInteractivityCallback(interactiveCallback);
    } catch (e) {
      // Silently fail if widget initialization fails
    }
  }

  Future<void> updateWidgetData() async {
    try {
      final isarService = IsarService();
      final allManga = await isarService.getAllManga();

      final readingManga =
          allManga
              .where((m) => m.readingStatus == ReadingStatus.reading)
              .toList()
            ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

      MangaItem? upNext;
      if (readingManga.isNotEmpty) {
        upNext = readingManga.first;
      }

      if (upNext != null) {
        await _saveUpNextWidgetData(upNext);
      } else {
        await HomeWidget.saveWidgetData<String>(
          _widgetTitleKey,
          'No manga in progress',
        );
        await HomeWidget.saveWidgetData<int>(_widgetCurrentChapterKey, 0);
        await HomeWidget.saveWidgetData<int?>(_widgetTotalChaptersKey, null);
        await HomeWidget.saveWidgetData<String>(_widgetMangaIdKey, '');
        await HomeWidget.saveWidgetData<String?>(_widgetCoverUrlKey, null);
      }

      final endDate = DateTime.now();
      final startDate = endDate.subtract(
        const Duration(days: 34),
      ); // 35 days total
      final logs = await isarService.getReadingLogsInRange(startDate, endDate);

      List<int> heatmapData = List.filled(35, 0);
      List<String> heatmapDates = List.filled(35, '');

      for (int i = 0; i < 35; i++) {
        final d = startDate.add(Duration(days: i));
        heatmapDates[i] =
            "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      }

      for (final log in logs) {
        final diff = log.date
            .difference(
              DateTime(startDate.year, startDate.month, startDate.day),
            )
            .inDays;
        if (diff >= 0 && diff < 35) {
          // ensure past reading doesn't pollute heatmap if property exists
          heatmapData[diff] += log.chaptersRead;
        }
      }

      await HomeWidget.saveWidgetData<String>(
        'widget_heatmap_data',
        jsonEncode(heatmapData),
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_heatmap_dates',
        jsonEncode(heatmapDates),
      );

      // Update Native Widgets
      await HomeWidget.updateWidget(
        androidName: 'UpNextWidgetProvider',
        iOSName: 'UpNextWidget',
      );
      await HomeWidget.updateWidget(
        androidName: 'HeatmapWidgetProvider',
        iOSName: 'HeatmapWidget',
      );
    } catch (e) {
      // Silently fail if widget update fails
    }
  }

  Future<void> handleWidgetAction(Uri? uri) async {
    if (uri == null) return;

    try {
      final action = uri.host;
      final mangaId = uri.queryParameters['mangaId'];

      if (action == 'increment' && mangaId != null) {
        final isarService = IsarService();
        final didIncrement = await isarService.incrementChapter(mangaId);

        if (didIncrement) {
          final updatedManga = await isarService.getMangaByMangaDexId(mangaId);
          if (updatedManga != null) {
            await _saveUpNextWidgetData(updatedManga);
            await HomeWidget.updateWidget(
              androidName: 'UpNextWidgetProvider',
              iOSName: 'UpNextWidget',
            );
          }
        }

        await updateWidgetData();
      }
    } catch (e) {
      // Silently fail if action handling fails
    }
  }
}

Future<void> _saveUpNextWidgetData(MangaItem manga) async {
  await HomeWidget.saveWidgetData<String>(_widgetTitleKey, manga.title);
  await HomeWidget.saveWidgetData<int>(
    _widgetCurrentChapterKey,
    manga.chapterProgress,
  );
  await HomeWidget.saveWidgetData<int?>(
    _widgetTotalChaptersKey,
    manga.totalChapters,
  );
  await HomeWidget.saveWidgetData<String>(_widgetMangaIdKey, manga.mangaDexId);
  await HomeWidget.saveWidgetData<String?>(_widgetCoverUrlKey, manga.coverUrl);
}

@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final service = WidgetService();
  try {
    await HomeWidget.setAppGroupId(_appGroupId);
    await IsarService().openDB();
    await service.handleWidgetAction(uri);
  } finally {
    await HomeWidget.updateWidget(
      androidName: 'UpNextWidgetProvider',
      iOSName: 'UpNextWidget',
    );
    await HomeWidget.updateWidget(
      androidName: 'HeatmapWidgetProvider',
      iOSName: 'HeatmapWidget',
    );
  }
}

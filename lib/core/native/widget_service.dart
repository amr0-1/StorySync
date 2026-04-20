import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:storysync/core/database/isar_service.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';

const String _appGroupId = 'group.com.storysync.app';
const String _androidWidgetName = 'StorySyncWidgetProvider';
const String _iOSWidgetName = 'StorySyncWidget';

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

      final readingManga = allManga
          .where((m) => m.readingStatus == ReadingStatus.reading)
          .toList()
        ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

      MangaItem? upNext;
      if (readingManga.isNotEmpty) {
        upNext = readingManga.first;
      }

      if (upNext != null) {
        await HomeWidget.saveWidgetData<String>(_widgetTitleKey, upNext.title);
        await HomeWidget.saveWidgetData<int>(_widgetCurrentChapterKey, upNext.chapterProgress);
        await HomeWidget.saveWidgetData<int?>(_widgetTotalChaptersKey, upNext.totalChapters);
        await HomeWidget.saveWidgetData<String>(_widgetMangaIdKey, upNext.mangaDexId);
        await HomeWidget.saveWidgetData<String?>(_widgetCoverUrlKey, upNext.coverUrl);
      } else {
        await HomeWidget.saveWidgetData<String>(_widgetTitleKey, 'No manga in progress');
        await HomeWidget.saveWidgetData<int>(_widgetCurrentChapterKey, 0);
        await HomeWidget.saveWidgetData<int?>(_widgetTotalChaptersKey, null);
        await HomeWidget.saveWidgetData<String>(_widgetMangaIdKey, '');
        await HomeWidget.saveWidgetData<String?>(_widgetCoverUrlKey, null);
      }

      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iOSWidgetName,
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
        await isarService.incrementChapter(mangaId);
        await updateWidgetData();
      }
    } catch (e) {
      // Silently fail if action handling fails
    }
  }
}

@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? uri) async {
  final service = WidgetService();
  await service.handleWidgetAction(uri);
}
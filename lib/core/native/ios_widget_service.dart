import 'package:flutter/cupertino.dart';
import 'package:home_widget/home_widget.dart';

class IosWidgetService {
  static Future<void> initialize() async {
    // iOS WidgetKit requires manual setup in Xcode
    // The widget will be created as a Widget Extension target in Xcode
  }

  static Future<void> updateWidgetData() async {
    // Similar to Android - data is shared via App Group
    // iOS uses UserDefaults with App Group container
    await HomeWidget.updateWidget(iOSName: 'StorySyncWidget');
  }

  static Future<void> handleWidgetUrl(Uri? uri) async {
    // Handle widget interactions
    if (uri == null) return;

    final action = uri.host;
    final mangaId = uri.queryParameters['mangaId'];

    if (action == 'increment' && mangaId != null) {
      // Handle increment through Flutter
    }
  }
}

/// Widget configuration constants for iOS
class IosWidgetConfig {
  static const String appGroupId = 'group.com.storysync.app';
  static const String widgetName = 'StorySyncWidget';

  // Void Ink Theme Colors
  static const Color inkVoid = Color(0xFF121214);
  static const Color ceramic = Color(0xFF1A1A1E);
  static const Color brushedSteel = Color(0xFF2C2C32);
  static const Color goldSpark = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8D48A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFF666666);
}

/// Widget that can be embedded in Flutter for preview
class WidgetPreview extends StatelessWidget {
  final String title;
  final int currentChapter;
  final int? totalChapters;
  final VoidCallback? onIncrement;

  const WidgetPreview({
    super.key,
    required this.title,
    required this.currentChapter,
    this.totalChapters,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IosWidgetConfig.inkVoid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C32), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'StorySync',
                style: TextStyle(
                  color: IosWidgetConfig.goldLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'UP NEXT',
                style: TextStyle(
                  color: IosWidgetConfig.textHint,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: IosWidgetConfig.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Ch. $currentChapter',
                          style: const TextStyle(
                            color: IosWidgetConfig.goldSpark,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (totalChapters != null && totalChapters! > 0)
                          Text(
                            ' / $totalChapters',
                            style: const TextStyle(
                              color: IosWidgetConfig.textHint,
                              fontSize: 14,
                              fontFamily: 'monospace',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Increment button
              GestureDetector(
                onTap: onIncrement,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: IosWidgetConfig.goldSpark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '+1',
                      style: TextStyle(
                        color: Color(0xFF08080A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

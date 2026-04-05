import 'package:flutter/material.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';

/// A reusable empty state widget for displaying when content is unavailable
class EmptyState extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The main title text
  final String title;

  /// The subtitle/description text
  final String subtitle;

  /// Optional action button
  final Widget? action;

  const EmptyState({
    super.key,
    this.icon = Icons.menu_book_rounded,
    required this.title,
    required this.subtitle,
    this.action,
  });

  /// Factory constructor for empty library state
  factory EmptyState.library() {
    return const EmptyState(
      icon: Icons.collections_bookmark_rounded,
      title: 'Your library is empty',
      subtitle: 'Start tracking manga by searching for titles in Discover',
    );
  }

  /// Factory constructor for no search results
  factory EmptyState.noResults({String? query}) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'No results found',
      subtitle: query != null
          ? 'No manga found for "$query"'
          : 'Try a different search term',
    );
  }

  /// Factory constructor for network error - uses Builder for dynamic colors
  static Widget networkError({VoidCallback? onRetry}) {
    return Builder(
      builder: (context) {
        final colors = Theme.of(context).extension<VoidInkColors>()!;
        return EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Connection error',
          subtitle: 'Please check your internet connection',
          action: onRetry != null
              ? TextButton(
                  onPressed: onRetry,
                  child: Text(
                    'Retry',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.goldSpark,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(icon, size: 64, color: colors.textHint),
            const SizedBox(height: AppDimensions.space16),

            // Title
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),

            // Subtitle
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),

            // Optional action
            if (action != null) ...[
              const SizedBox(height: AppDimensions.space16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
